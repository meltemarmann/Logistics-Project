/*********************************************
 * OPL 22.1.0.0 Model
 * Author: asus
 * Creation Date: 17 Tem 2022 at 13:46:41
 *********************************************/
range N= 1..15;

 //Parametreler
 
float d[N][N] = ...; //�ube i'nin �ube j'ye olan talebi
float t[N][N] = ...; //i �ehri ve j �ehri aras�ndaki mesafe
float Ve[N][N] = ...; //E�er i �ehrinden j �ehrine olan mesafe 300 km'den k���kse 1, de�ilse 0
float Vd[N][N] = ...; //E�er i �ehrinden j �ehrine olan mesafe 300 km'den b�y�kse 1, de�ilse 0
int p = 3; //A��lacak transfer merkezi say�s�
int vt = 70; //T�rlar�n ortalama h�z�(km/saat)
int vp = 80; //Panelvanlar�n ortalama h�z� (km/saat)

float cd = 1; //Dizel ara�lar�n ta��ma maliyetleri(TL/km)


float pd = 800; //Dizel ara�lar�n sat�n alma malietleri
float O[N]=...; // i'�unesinden ��kmas� gereken toplam ak��
float D[N]=...;// i �ubesine gelen toplam ak��
  
float a = 0.8; // �l�ek ekonomisi fakt�r�
float M=5000000;

 //De�i�kenler

dvar boolean X[N][N]; // 1; e�er i noktas� k transfer merkezine atand�ysa, 0; di�er durumlarda
dvar float+ Y[N][N][N]; // var�� noktas� i'den ��k�p s�ra ile k ve l transfer merkezlerine y�nlenen toplam ak��
dvar float I[N];  // i transfer merkezinden teslimat�n 3. aya�� i�in yola ��k�labilecek en erken s�re 
dvar boolean Z[N][N][N]; // 1; e�er Y de�i�keni 0'dan b�y�kse, 0; di�er durumda
dvar float L[N];

//Matematiksel Model
minimize sum(i in N,k in N)O[i]*(cd-Ve[i][k]*0.1)*t[i][k]*X[i][k] +  sum(i in N, k in N,l in N) a*cd*t[k][l]*Y[i][k][l]+ sum(j in N,l in N) D[j]*(cd-Ve[j][l]*0.2)*t[j][l]*X[j][l]
+ sum(i in N , j in N)(pd+300*Ve[i][j])*X[i][j] +sum(j in N)L[j];
             
subject to{

forall (i in N){
  sum(k in N)X[i][k] ==1; // Her �ube yaln�zca bir transfre merkezine atanmal�
}

forall(i in N,k in N){
  X[i][k]<=X[k][k];        //Yaln�zca bir �ubenin transfer merkezi olmas� durumunda o transfer merkezine di�er �ubeler atanabilir
}

sum(k in N)X[k][k] == p;  //Bir �ube kendisine atand�ysa oras� bir transfer merkezidir ve yaln�zca p kadar transfer merkezi a��labilir

forall(i in N, k in N){
  (O[i]*X[i][k]+ sum(l in N)Y[i][l][k])== (sum(l in N)Y[i][k][l] + sum(j in N)d[i][j]*X[j][k]);
}
forall(i in N,k in N, l in N){  //ili�kilendirme
  Y[i][k][l]<= X[k][k]*M;
  Y[i][k][l]<= X[l][l]*M;
}
forall (i in N,k in N,l in N){  //ili�kilendirme
  Y[i][k][l] <= Z[i][k][l]*M;
  Z[i][k][l] <= Y[i][k][l];
}

forall (k in N, m in N: m !=k,i in N,j in N){    //zaman k�s�tlar�
   
   I[k] >= t[i][k]*X[i][k]/vp;
   I[k] + t[j][k]*X[j][k]/vp <= 24*X[k][k];
   I[k] >= (t[i][m]*Z[i][m][k])/vp + t[m][k]*X[k][k]/vt;
   I[k] + t[j][k]*X[j][k]/vp <= L[j];
}


}