function [eigvec eigval] = LPP(fea, alpha)

k = 5;
t = 1e4;

% nSmp = jumlah sampel yang digunakan dalam proses ekstraksi ciri
[nSmp, nFea] = size(fea);

% Menentukan kapasitas/alokasi maksimum dari memori yang digunakan
maxM = 62500000;

% Ukuran blok iterasi yang dibentuk untuk jumlah sampel = nSmp
BlockSize = floor(maxM / (nSmp * 3));

% Graf nearest-neighbor (S) untuk menyimpan informasi nilai bobot ketetanggaan antar
% image menggunakan bobot heat kernel
G = zeros(nSmp * (k + 1), 3);

for i = 1:ceil(nSmp / BlockSize)
    if i == ceil(nSmp / BlockSize)
        smpIdx = (i - 1) * BlockSize + 1:nSmp;
        dist = EuDist2(fea(smpIdx, :), fea, 0);
        dist = full(dist);
        [val idx] = sort(dist, 2);
        idx = idx(:, 1:k + 1);
        val = val(:, 1:k + 1);
        val = exp(-val / (2 * t ^ 2));
        G((i - 1) * BlockSize * (k + 1) + 1:nSmp * (k + 1), 1) = repmat(smpIdx', [k + 1, 1]);
        G((i - 1) * BlockSize * (k + 1) + 1:nSmp * (k + 1), 2) = idx(:);
        G((i - 1) * BlockSize * (k + 1) + 1:nSmp * (k + 1), 3) = val(:);
    else
        smpIdx = (i - 1) * BlockSize + 1:i * BlockSize;
        dist = EuDist2(fea(smpIdx, :), fea, 0);
        dist = full(dist);
        [val idx] = sort(dist, 2);
        idx = idx(:, 1:k + 1);
        val = val(:, 1:k + 1);
        val = exp(-val / (2 * t ^ 2));
        G((i - 1) * BlockSize * (k + 1) + 1:i * BlockSize * (k + 1), 1) = repmat(smpIdx', [k + 1, 1]);
        G((i - 1) * BlockSize * (k + 1) + 1:i * BlockSize * (k + 1), 2) = idx(:);
        G((i - 1) * BlockSize * (k + 1) + 1:i * BlockSize * (k + 1), 3) = val(:);
    end
end

W = sparse(G(:, 1), G(:, 2), G(:, 3), nSmp, nSmp);

% Mendapatkan mean image
sampleMean = mean(fea);
fea = (fea - repmat(sampleMean, nSmp, 1));

% D adalah sebuah vektor hasil penjumlahan kolom/baris dari W
D = full(sum(W, 2));

% Akarkan semua elemen nilai pada vektor D
DToPowerHalf = D.^.5;

% D = 1/sqrt(D)
D_mhalf = DToPowerHalf.^-1;

if nSmp < 5000
	 % Membuat salinan vektor D sebanyak jumlah sampel data
    tmpD_mhalf = repmat(D_mhalf, 1, nSmp);
	 
	 % Kalikan vektor D dengan W menggunakan dot product kemudian kalikan 
	 % hasilnya dengan vektor D dengan transpos dari D menggunakan dot product
    W = (tmpD_mhalf .* W) .* tmpD_mhalf';
	 
    clear tmpD_mhalf;
else
    [i_idx, j_idx, v_idx] = find(W);
    v1_idx = zeros(size(v_idx));
    for i=1:length(v_idx)
        v1_idx(i) = v_idx(i) * D_mhalf(i_idx(i)) * D_mhalf(j_idx(i));
    end
    W = sparse(i_idx, j_idx, v1_idx);
    clear i_idx j_idx v_idx v1_idx
end
W = max(W, W');

% Lakukan perkalian dot product antara vektor D yang semua elemennya
% telah diakar dengan matriks dataset (XD)
fea = repmat(DToPowerHalf, 1, nFea) .* fea;

options = [];

% Mengambil dimensi dari eigenvector sesuai alpha * jumlah sampel (prosentase jumlah eigenvector yang diambil)
Dim = floor(alpha * nSmp);

bPCA = 1;
options.PCARatio = 1;
bChol = 0;

%======================================
% SVD
%======================================

% Menghitung D' = XDX'

ddata = fea * fea'; 
if issparse(ddata)
    ddata = full(ddata);
end
ddata = max(ddata, ddata');

% Mendapatkan nilai eigenvalue dan eigenvector dari XDX'
[eigvector, eigvalue_PCA] = eig(ddata);
eigvalue_PCA = diag(eigvalue_PCA);
clear ddata;

% Mengeliminasi eigenvector dan eigenvalue jika nilai (eigenvalue/maxEigenValue) < 1e12
maxEigValue = max(eigvalue_PCA);
eigIdx = find(eigvalue_PCA / maxEigValue < 1e-12);
eigvalue_PCA(eigIdx) = [];
eigvector(:, eigIdx) = [];

[~, index] = sort(-eigvalue_PCA);
eigvalue_PCA = eigvalue_PCA(index);
eigvector = eigvector(:, index);

eigvalue_PCA = eigvalue_PCA.^.5;
eigvalue_PCAMinus = eigvalue_PCA.^-1;

eigvector_PCA = (fea' * eigvector) .* repmat(eigvalue_PCAMinus', nFea, 1);
fea = eigvector;
eigvalue_PCA = eigvalue_PCAMinus;

clear eigvector;

WPrime = fea' * W * fea;
WPrime = max(WPrime, WPrime');

%======================================
% Generalized Eigen
%======================================

dimMatrix = size(WPrime, 2);

if Dim > dimMatrix
    Dim = dimMatrix;
end

if (dimMatrix > 1000 & Dim < dimMatrix / 10) | (dimMatrix > 500 & Dim < dimMatrix / 20) | (dimMatrix > 250 & Dim < dimMatrix / 30)
    bEigs = 1;
else
    bEigs = 0;
end

if bEigs
    option = struct('disp', 0);
		  [eigvector, eigvalue] = eigs(WPrime, Dim, 'la', option);
    eigvalue = diag(eigvalue);
else
    [eigvector, eigvalue] = eig(WPrime);
    eigvalue = diag(eigvalue);

    [~, index] = sort(-eigvalue);
    eigvalue = eigvalue(index);
    eigvector = eigvector(:, index);
    
    if Dim < size(eigvector,2)
        eigvector = eigvector(:, 1:Dim);
        eigvalue = eigvalue(1:Dim);
    end
end

eigvector = eigvector_PCA * (repmat(eigvalue_PCA, 1, length(eigvalue)) .* eigvector);

for i=1 : size(eigvector, 2)
    eigvector(:, i) = eigvector(:, i) ./ norm(eigvector(:,i));
end

eigvec = eigvector;
eigval = eigvalue;

clear eigvector eigvalue;


