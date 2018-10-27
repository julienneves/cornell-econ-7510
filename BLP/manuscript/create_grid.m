function grid = create_grid(X, Y, nGrid)
%creategrid Create search grid for parameters
%   [] = creategrid(X, Y, nGrid) returns a matrix with each row
%   representing a point on the grid spanned by the bounds X and Y
%   with nGrid different points
%
%   Author: Julien Neves
%   Date: 2018-10-09

nParams = numel(X);
if nargin < 4
    grid = X+rand(nParams,nGrid).*(Y-X);
    
else
    if ~iscolumn(X)||~iscolumn(Y)
        error('Error. X or Y are not column vectors.')
    end
    if nParams~=numel(Y)
        error('Error. X or Y are not same length.')
    end
    
    
    n = ceil(nGrid^(1/nParams));
    
    X = X';
    Y = Y';
    Z = X + linspace(0, 1, n)'.*(Y-X);
    % Create index grid
    a = repmat(n,1,nParams);
    b = cumsum(a);
    index = fullfact(a) + [0, b(1:end-1)];
    
    % Return
    grid = Z(index)';
end

end