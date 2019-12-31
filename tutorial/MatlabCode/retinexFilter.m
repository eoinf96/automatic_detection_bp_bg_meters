%Code editted from: https://github.com/KirillLykov/cvision-algorithms


% (C) Copyright Kirill Lykov 2013.
%
% Distributed under the FreeBSD Software License 

% THIS SOFTWARE IS PROVIDED BY KIRILL LYKOV ''AS IS'' AND ANY
% EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL KIRILL LYKOV BE LIABLE FOR ANY
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
% ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


function output = retinexFilter( image, sigmaSpatial, sigmaRange, ... 
     samplingSpatial, samplingRange, gamma, showPlots )
    % should be applied to the v channel of HSV picture
    % following notations by Elad. Based on paper Retinex by two bilateral
    % filters.
    % http://www.cs.technion.ac.il/~elad/talks/2005/Retinex-ScaleSpace-Short.pdf

    % 1. transform to ln
    image( image == 0 ) = image( image == 0 ) + 0.001; % to avoid inf values for log
    illumination = log(image);
    reflection = illumination;

    % 2. find illumination by filtering with envelope mode
    illumination = fastBilateralFilter(illumination, sigmaSpatial, sigmaRange, samplingSpatial, samplingRange);
%     illumination = regBilateralFilter(illumination, 1, sigmaSpatial, sigmaRange, 15);
    if (showPlots == 1)
        subplot(222);
        imagesc(illumination);
    end;

    % 3. find reflection by filtering with regular mode
    % at this point reflection stores original image
    reflection = (reflection - illumination);
    reflection = fastBilateralFilter(reflection, sigmaSpatial, sigmaRange, samplingSpatial, samplingRange);
%     reflection = regBilateralFilter(reflection, 0, sigmaSpatial, sigmaRange, 5);
%     subplot(223);
%     imagesc(exp(illumination));

    % 4. apply gamma correction to illumination
    illumination = 1/gamma*illumination; %1.0/gamma*(illumination - log(255)) + log(255); % for [1,255]
    if (showPlots == 1)
        subplot(224);
        imagesc(exp(illumination));
    end;

    % 5. S_res = exp(s_res) = exp( illumination_corrected + reflection )
    output = exp( reflection + illumination);

end
