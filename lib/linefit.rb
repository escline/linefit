# == Synopsis
#
# Weighted or unweighted least-squares line fitting to two-dimensional data (y = a + b * x).
# (This is also called linear regression.)
#
# == Usage
#
#  x = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
#  y = [4039,4057,4052,4094,4104,4110,4154,4161,4186,4195,4229,4244,4242,4283,4322,4333,4368,4389]
#
#  linefit = LineFit.new
#  linefit.setData(x,y)
#
#  intercept, slope = linefit.coefficients
#  rSquared = linefit.rSquared
#  meanSquaredError = linefit.meanSqError
#  durbinWatson = linefit.durbinWatson
#  sigma = linefit.sigma
#  tStatIntercept, tStatSlope = linefit.tStatistics
#  predictedYs = linefit.predictedYs
#  residuals = linefit.residuals
#  varianceIntercept, varianceSlope = linefit.varianceOfEstimates
#
#  newX = 24
#  newY = linefit.forecast(newX)
#
# == Authors
# Eric Cline,  escline(at)gmail(dot)com,       ( Ruby Port, LineFit#forecast )
#
#
# Richard Anderson                           ( Statistics::LineFit Perl module )
# http://search.cpan.org/~randerson/Statistics-LineFit-0.07
#
# == See Also
#     Mendenhall, W., and Sincich, T.L., 2003, A Second Course in Statistics:
#       Regression Analysis, 6th ed., Prentice Hall.
#     Press, W. H., Flannery, B. P., Teukolsky, S. A., Vetterling, W. T., 1992,
#       Numerical Recipes in C : The Art of Scientific Computing, 2nd ed.,
#       Cambridge University Press.
#
# == License
# Licensed under the same terms as Ruby.
#

class LineFit

   ############################################################################
   # Create a LineFit object with the optional validate and hush parameters
   #
   #  linefit = LineFit.new
   #  linefit = LineFit.new(validate)
   #  linefit = LineFit.new(validate, hush)
   #
   #  validate = 1 -> Verify input data is numeric (slower execution)
   #           = 0 -> Don't verify input data (default, faster execution)
   #  hush     = 1 -> Suppress error messages
   #           = 0 -> Enable error messages (default)

   def initialize(validate = false, hush = false)
      @doneRegress = false
      @gotData = false
      @hush = hush
      @validate = validate
   end

   ############################################################################
   # Return the slope and intercept from least squares line fit
   #
   #  intercept, slope = linefit.coefficients
   #
   # The returned list is undefined if the regression fails.
   #
   def coefficients
      self.regress unless (@intercept and @slope)
      return @intercept, @slope
   end

   ############################################################################
   # Return the Durbin-Watson statistic
   #
   #  durbinWatson = linefit.durbinWatson
   #
   # The Durbin-Watson test is a test for first-order autocorrelation in the
   # residuals of a time series regression. The Durbin-Watson statistic has a
   # range of 0 to 4; a value of 2 indicates there is no autocorrelation.
   #
   # The return value is undefined if the regression fails. If weights are
   # input, the return value is the weighted Durbin-Watson statistic.
   #
   def durbinWatson
      unless @durbinWatson
         self.regress or return
         sumErrDiff = 0
         errorTMinus1 = @y[0] - (@intercept + @slope * @x[0])
         1.upto(@numxy-1) do |i|
            error = @y[i] - (@intercept + @slope * @x[i])
            sumErrDiff += (error - errorTMinus1) ** 2
            errorTMinus1 = error
         end
         @durbinWatson = sumSqErrors() > 0 ? sumErrDiff / sumSqErrors() : 0
      end
      return @durbinWatson
   end

   ############################################################################
   # Return the mean squared error
   #
   #  meanSquaredError = linefit.meanSqError
   #
   # The return value is undefined if the regression fails. If weights are
   # input, the return value is the weighted mean squared error.
   #
   def meanSqError
      unless @meanSqError
         self.regress or return
         @meanSqError = sumSqErrors() / @numxy
      end
      return @meanSqError
   end

   ############################################################################
   # Return the predicted Y values
   #
   #  predictedYs = linefit.predictedYs
   #
   # The returned list is undefined if the regression fails.
   #
   def predictedYs
      unless @predictedYs
         self.regress or return
         @predictedYs = []
         0.upto(@numxy-1) do |i|
            @predictedYs[i] = @intercept + @slope * @x[i]
         end
      end
      return @predictedYs
   end

   ############################################################################
   # Return the independent (Y) value, by using a dependent (X) value
   #
   #  forecasted_y = linefit.forecast(x_value)
   #
   # Will use the slope and intercept to calculate the Y value along the line
   # at the x value. Note: value returned only as good as the line fit.
   #
   def forecast(x)
      self.regress unless (@intercept and @slope)
      return @slope * x + @intercept
   end

   ############################################################################
   # Do the least squares line fit (if not already done)
   #
   #  linefit.regress
   #
   # You don't need to call this method because it is invoked by the other
   # methods as needed. After you call setData(), you can call regress() at
   # any time to get the status of the regression for the current data.
   #
   def regress
      return @regressOK if @doneRegress
      unless @gotData
         puts "No valid data input - can't do regression" unless @hush
         return false
      end
      sumx, sumy, @sumxx, sumyy, sumxy = computeSums()
      @sumSqDevx = @sumxx - sumx ** 2 / @numxy
      if @sumSqDevx != 0
         @sumSqDevy  = sumyy - sumy ** 2 / @numxy
         @sumSqDevxy = sumxy - sumx * sumy / @numxy
         @slope      = @sumSqDevxy / @sumSqDevx
         @intercept  = (sumy - @slope * sumx) / @numxy
         @regressOK = true
      else
         puts "Can't fit line when x values are all equal" unless @hush
         @sumxx = @sumSqDevx = nil
         @regressOK = false
      end
      @doneRegress = true
      return @regressOK
   end

   ############################################################################
   # Return the predicted Y values minus the observed Y values
   #
   #  residuals = linefit.residuals
   #
   # The returned list is undefined if the regression fails.
   #
   def residuals
      unless @residuals
         self.regress or return
         @residuals = []
         0.upto(@numxy-1) do |i|
            @residuals[i] = @y[i] - (@intercept + @slope * @x[i])
         end
      end
      return @residuals
   end

   ############################################################################
   # Return the correlation coefficient
   #
   #  rSquared = linefit.rSquared
   #
   # R squared, also called the square of the Pearson product-moment
   # correlation coefficient, is a measure of goodness-of-fit. It is the
   # fraction of the variation in Y that can be attributed to the variation
   # in X. A perfect fit will have an R squared of 1; fitting a line to the
   # vertices of a regular polygon will yield an R squared of zero. Graphical
   # displays of data with an R squared of less than about 0.1 do not show a
   # visible linear trend.
   #
   # The return value is undefined if the regression fails. If weights are
   # input, the return value is the weighted correlation coefficient.
   #
   def rSquared
      unless @rSquared
         self.regress or return
         denom = @sumSqDevx * @sumSqDevy
         @rSquared = denom != 0 ? @sumSqDevxy ** 2 / denom : 1
      end
      return @rSquared
   end

   ############################################################################
   # Initialize (x,y) values and optional weights
   #
   #  lineFit.setData(x, y)
   #  lineFit.setData(x, y, weights)
   #  lineFit.setData(xy)
   #  lineFit.setData(xy, weights)
   #
   # xy is an array of arrays; x values are xy[i][0], y values are
   # xy[i][1]. The method identifies the difference between the first
   # and fourth calling signatures by examining the first argument.
   #
   # The optional weights array must be the same length as the data array(s).
   # The weights must be non-negative numbers; at least two of the weights
   # must be nonzero. Only the relative size of the weights is significant:
   # the program normalizes the weights (after copying the input values) so
   # that the sum of the weights equals the number of points. If you want to
   # do multiple line fits using the same weights, the weights must be passed
   # to each call to setData().
   #
   # The method will return flase if the array lengths don't match, there are
   # less than two data points, any weights are negative or less than two of
   # the weights are nonzero. If the new() method was called with validate =
   # 1, the method will also verify that the data and weights are valid
   # numbers. Once you successfully call setData(), the next call to any
   # method other than new() or setData() invokes the regression.
   #
   def setData(x, y = nil, weights = nil)
      @doneRegress = false
      @x = @y = @numxy = @weight = \
         @intercept = @slope = @rSquared = \
         @sigma = @durbinWatson = @meanSqError = \
         @sumSqErrors = @tStatInt = @tStatSlope = \
         @predictedYs = @residuals = @sumxx = \
         @sumSqDevx = @sumSqDevy = @sumSqDevxy = nil
      if x.length < 2
         puts "Must input more than one data point!" unless @hush
         return false
      end
      if x[0].class == Array
         @numxy = x.length
         setWeights(y) or return false
         @x = []
         @y = []
         x.each do |xy|
            @x << xy[0]
            @y << xy[1]
         end
      else
         if x.length != y.length
            puts "Length of x and y arrays must be equal!" unless @hush
            return false
         end
         @numxy = x.length
         setWeights(weights) or return false
         @x = x
         @y = y
      end
      if @validate
         unless validData()
            @x = @y = @weights = @numxy = nil
            return false
         end
      end
      @gotData = true
      return true
   end

   ############################################################################
   # Return the estimated homoscedastic standard deviation of the
   # error term
   #
   # sigma = linefit.sigma
   #
   # Sigma is an estimate of the homoscedastic standard deviation of the
   # error. Sigma is also known as the standard error of the estimate.
   #
   # The return value is undefined if the regression fails. If weights are
   # input, the return value is the weighted standard error.
   #
   def sigma
      unless @sigma
         self.regress or return
         @sigma = @numxy > 2 ? Math.sqrt(sumSqErrors() / (@numxy - 2)) : 0
      end
      return @sigma
   end

   ############################################################################
   # Return the T statistics
   #
   #  tStatIntercept, tStatSlope = linefit.tStatistics
   #
   # The t statistic, also called the t ratio or Wald statistic, is used to
   # accept or reject a hypothesis using a table of cutoff values computed
   # from the t distribution. The t-statistic suggests that the estimated
   # value is (reasonable, too small, too large) when the t-statistic is
   # (close to zero, large and positive, large and negative).
   #
   # The returned list is undefined if the regression fails. If weights are
   # input, the returned values are the weighted t statistics.
   #
   def tStatistics
      unless (@tStatInt and @tStatSlope)
         self.regress or return
         biasEstimateInt = sigma() * Math.sqrt(@sumxx / (@sumSqDevx * @numxy))
         @tStatInt = biasEstimateInt != 0 ? @intercept / biasEstimateInt : 0
         biasEstimateSlope = sigma() / Math.sqrt(@sumSqDevx)
         @tStatSlope = biasEstimateSlope != 0 ? @slope / biasEstimateSlope : 0
      end
      return @tStatInt, @tStatSlope
   end

   ############################################################################
   # Return the variances in the estiamtes of the intercept and slope
   #
   #  varianceIntercept, varianceSlope = linefit.varianceOfEstimates
   #
   # Assuming the data are noisy or inaccurate, the intercept and slope
   # returned by the coefficients() method are only estimates of the true
   # intercept and slope. The varianceofEstimate() method returns the
   # variances of the estimates of the intercept and slope, respectively. See
   # Numerical Recipes in C, section 15.2 (Fitting Data to a Straight Line),
   # equation 15.2.9.
   #
   # The returned list is undefined if the regression fails. If weights are
   # input, the returned values are the weighted variances.
   #
   def varianceOfEstimates
      unless @intercept and @slope
         self.regress or return
      end
      predictedYs = predictedYs()
      s = sx = sxx = 0
      if @weight
         0.upto(@numxy-1) do |i|
            variance = (predictedYs[i] - @y[i]) ** 2
            unless variance == 0
               s   += 1.0 / variance
               sx  += @weight[i] * @x[i] / variance
               sxx += @weight[i] * @x[i] ** 2 / variance
            end
         end
      else
         0.upto(@numxy-1) do |i|
            variance = (predictedYs[i] - @y[i]) ** 2
            unless variance == 0
               s   += 1.0 / variance
               sx  += @x[i] / variance
               sxx += @x[i] ** 2 / variance
            end
         end
      end
      denominator = (s * sxx - sx ** 2)
      if denominator == 0
         return
      else
         return sxx / denominator, s / denominator
      end
   end

private

   ############################################################################
   # Compute sum of x, y, x**2, y**2, and x*y
   #
   def computeSums
      sumx = sumy = sumxx = sumyy = sumxy = 0
      if @weight
         0.upto(@numxy-1) do |i|
            sumx  += @weight[i] * @x[i]
            sumy  += @weight[i] * @y[i]
            sumxx += @weight[i] * @x[i] ** 2
            sumyy += @weight[i] * @y[i] ** 2
            sumxy += @weight[i] * @x[i] * @y[i]
         end
      else
         0.upto(@numxy-1) do |i|
            sumx  += @x[i]
            sumy  += @y[i]
            sumxx += @x[i] ** 2
            sumyy += @y[i] ** 2
            sumxy += @x[i] * @y[i]
         end
      end
      # Multiply each return value by 1.0 to force them to Floats
      return sumx * 1.0, sumy * 1.0, sumxx * 1.0, sumyy * 1.0, sumxy * 1.0
   end

   ############################################################################
   # Normalize and initialize line fit weighting factors
   #
   def setWeights(weights = nil)
      return true unless weights
      if weights.length != @numxy
         puts "Length of weight array must equal length of data array!" unless @hush
         return false
      end
      if @validate
         validWeights(weights) or return false
      end
      sumw = numNonZero = 0
      weights.each do |weight|
         if weight < 0
            puts "Weights must be non-negative numbers!" unless @hush
            return false
         end
         sumw += weight
         numNonZero += 1 if weight != 0
      end
      if numNonZero < 2
         puts "At least two weights must be nonzero!" unless @hush
         return false
      end
      factor = weights.length.to_f / sumw
      weights.collect! {|weight| weight * factor}
      @weight = weights
      return true
   end

   ############################################################################
   # Return the sum of the squared errors
   #
   def sumSqErrors
      unless @sumSqErrors
         self.regress or return
         @sumSqErrors = @sumSqDevy - @sumSqDevx * @slope ** 2
         @sumSqErrors = 0 if @sumSqErrors < 0
      end
      return @sumSqErrors
   end

   ############################################################################
   # Verify that the input x-y data are numeric
   #
   def validData
      0.upto(@numxy-1) do |i|
         unless @x[i]
            puts "Input x[#{i}] is not defined" unless @hush
            return false
         end
         if @x[i] !~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/
            puts "Input x[#{i}] is not a number: #{@x[i]}" unless @hush
            return false
         end
         unless @y[i]
            puts "Input y[#{i}] is not defined" unless @hush
            return false
         end
         if @y[i] !~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/
            puts "Input y[#{i}] is not a number: #{@y[i]}" unless @hush
            return false
         end
      end
      return true
   end

   ############################################################################
   # Verify that the input weights are numeric
   #
   def validWeights(weights)
      0.upto(weights.length) do |i|
         unless weights[i]
            puts "Input weights[#{i}] is not defined" unless @hush
            return false
         end
         if weights[i] !~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/
            puts "Input weights[#{i}] is not a number: #{weights[i]}" unless @hush
            return false
         end
      end
      return true
   end

end
