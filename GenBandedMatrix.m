
BandSizes=[3,9,13,27];
MatrixSizes = [2000,120000,1000000];

for i =1:length(BandSizes)
    for j=1:length(MatrixSizes)
        band_width = (BandSizes(i) -1)/2;
        matrix_size  = MatrixSizes(j);
        A = spdiags(randn(matrix_size,2*band_width+1),...
             -band_width:band_width,matrix_size,matrix_size);
          filename =['Benchmarks/band' num2str(BandSizes(i)) '_n_' num2str(matrix_size) '.mtx'];
        mmwrite(filename,A);

    end
end



