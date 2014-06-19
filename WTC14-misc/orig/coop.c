// Cooperative bench coop.c

int f (int n) {
  int i;
  int s = 0;
  for (i=0;i<n;i++) 
    s+=i;
  return s;
}

int main (void) {
  int i,j,k;
  int s = 0;
  int n;
  int a [10];
  n = 5;
  //classical loop with dependancy on nested loop
  for (i = 0;  i <= n; i++)
    for (j = i; j <= n; j++) 
      s += j;
  //infeasible path, resulting of preceeding loop bound calculus
  if (j < n) {
    if (s>0) 
      s = 200;
    else 
      s=s*2;
  }
  else {
    if (s>0) 
      s=s*4;
    else 
      s=-200;
  }    
  // loop with break, followed by infeasible path (if full loop is not executed)      
  for (i=0;i<10;i++) {
    if ((i<5) && (a[i]>100)) 
      break;
    a[i]+=10;  
  }    
  if (i<10) 
    s=0; 
          
  // contextual loop bound
  s=f(10);
  s=f(5);
}
