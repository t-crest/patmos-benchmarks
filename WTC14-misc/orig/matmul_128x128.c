/* matmul.c */

#define SIZE 128

typedef int matrix_t[SIZE][SIZE];

void matmul (matrix_t a, matrix_t b, matrix_t c){
  int i,j,k;
  for (i=0 ; i<SIZE; i++){
    for (j=0 ; j<SIZE ; j++) {
      c[i][j] = 0;
      for (k=0 ; k< SIZE ; k++){
	c[i][j] += a[i][k] * b[k][j];
      }
    }
  }
}

int main(){
  matrix_t A,B,C;
  matmul(A,B,C);
  return 0;
}
