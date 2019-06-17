classdef BiasedSigmoidLayer < nnet.layer.Layer
   
    properties
        Beta
    end
    
    methods
        function this = BiasedSigmoidLayer(beta)
            this.Type = 'Biased Sigmoid';
            this.Description = 'Biased Sigmoid layer';
            this.Beta = beta;
        end
        
        function Z = predict( this, X )
            Z = iSigmoid(X,this.Beta);
        end
        
        function dLdX = backward( this, X, ~, dLdZ, ~ )
            dZdX = iSigmoid(X,this.Beta) .* (1-iSigmoid(X,this.Beta));
            dLdX = dLdZ.*dZdX;
        end
    end
end

function res = iSigmoid(X,beta)
res = 1./(1+exp(-X-beta));
end