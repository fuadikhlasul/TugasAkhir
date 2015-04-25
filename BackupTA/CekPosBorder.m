function hasil=cekPosBorder(x,y,C)
%berikan indeks pada matriks C
x;
y;
id=1: size(C,1);
C=cat(2,C,id');
%cari posisi baris
idx=find(C(:,1)==x);
%potong matriks C
C=C(idx,:);
%cari posisi kolom
idy=find(C(:,2)==y);
%potong matriks C
C=C(idy,:)
%ambil nilai pertama
hasil=C(1,3);
