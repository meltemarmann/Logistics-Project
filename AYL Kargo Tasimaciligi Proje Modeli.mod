/*********************************************
 * OPL 22.1.0.0 Model
 * Author: asus
 * Creation Date: 17 Tem 2022 at 13:46:41
 *********************************************/
range N= 1..15;

 //Parametreler
 
float d[N][N] = ...; //Þube i'nin þube j'ye olan talebi
float t[N][N] = ...; //i þehri ve j þehri arasýndaki mesafe
float Ve[N][N] = ...; //Eðer i þehrinden j þehrine olan mesafe 300 km'den küçükse 1, deðilse 0
float Vd[N][N] = ...; //Eðer i þehrinden j þehrine olan mesafe 300 km'den büyükse 1, deðilse 0
int p = 3; //Açýlacak transfer merkezi sayýsý
int vt = 70; //Týrlarýn ortalama hýzý(km/saat)
int vp = 80; //Panelvanlarýn ortalama hýzý (km/saat)

float cd = 1; //Dizel araçlarýn taþýma maliyetleri(TL/km)


float pd = 800; //Dizel araçlarýn satýn alma malietleri
float O[N]=...; // i'þunesinden çýkmasý gereken toplam akýþ
float D[N]=...;// i þubesine gelen toplam akýþ
  
float a = 0.8; // Ölçek ekonomisi faktörü
float M=5000000;

 //Deðiþkenler

dvar boolean X[N][N]; // 1; eðer i noktasý k transfer merkezine atandýysa, 0; diðer durumlarda
dvar float+ Y[N][N][N]; // varýþ noktasý i'den çýkýp sýra ile k ve l transfer merkezlerine yönlenen toplam akýþ
dvar float I[N];  // i transfer merkezinden teslimatýn 3. ayaðý için yola çýkýlabilecek en erken süre 
dvar boolean Z[N][N][N]; // 1; eðer Y deðiþkeni 0'dan büyükse, 0; diðer durumda
dvar float L[N];

//Matematiksel Model
minimize sum(i in N,k in N)O[i]*(cd-Ve[i][k]*0.1)*t[i][k]*X[i][k] +  sum(i in N, k in N,l in N) a*cd*t[k][l]*Y[i][k][l]+ sum(j in N,l in N) D[j]*(cd-Ve[j][l]*0.2)*t[j][l]*X[j][l]
+ sum(i in N , j in N)(pd+300*Ve[i][j])*X[i][j] +sum(j in N)L[j];
             
subject to{

forall (i in N){
  sum(k in N)X[i][k] ==1; // Her þube yalnýzca bir transfre merkezine atanmalý
}

forall(i in N,k in N){
  X[i][k]<=X[k][k];        //Yalnýzca bir þubenin transfer merkezi olmasý durumunda o transfer merkezine diðer þubeler atanabilir
}

sum(k in N)X[k][k] == p;  //Bir þube kendisine atandýysa orasý bir transfer merkezidir ve yalnýzca p kadar transfer merkezi açýlabilir

forall(i in N, k in N){
  (O[i]*X[i][k]+ sum(l in N)Y[i][l][k])== (sum(l in N)Y[i][k][l] + sum(j in N)d[i][j]*X[j][k]);
}
forall(i in N,k in N, l in N){  //iliþkilendirme
  Y[i][k][l]<= X[k][k]*M;
  Y[i][k][l]<= X[l][l]*M;
}
forall (i in N,k in N,l in N){  //iliþkilendirme
  Y[i][k][l] <= Z[i][k][l]*M;
  Z[i][k][l] <= Y[i][k][l];
}

forall (k in N, m in N: m !=k,i in N,j in N){    //zaman kýsýtlarý
   
   I[k] >= t[i][k]*X[i][k]/vp;
   I[k] + t[j][k]*X[j][k]/vp <= 24*X[k][k];
   I[k] >= (t[i][m]*Z[i][m][k])/vp + t[m][k]*X[k][k]/vt;
   I[k] + t[j][k]*X[j][k]/vp <= L[j];
}


}