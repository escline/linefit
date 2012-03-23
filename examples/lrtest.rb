require 'linefit'

lineFit = LineFit.new

x = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
y = [4039,4057,4052,4094,4104,4110,4154,4161,4186,4195,4229,4244,4242,4283,4322,4333,4368,4389]

lineFit.setData(x,y)

intercept, slope = lineFit.coefficients

rSquared = lineFit.rSquared

meanSquaredError = lineFit.meanSqError
durbinWatson = lineFit.durbinWatson
sigma = lineFit.sigma
tStatIntercept, tStatSlope = lineFit.tStatistics
predictedYs = lineFit.predictedYs
residuals = lineFit.residuals
varianceIntercept, varianceSlope = lineFit.varianceOfEstimates

print "\n*****  LineFit  *****\n"
print "Slope: #{slope}  Y-Intercept: #{intercept}\n"
print "r-Squared: #{rSquared}\n"
print "Mean Squared Error: #{meanSquaredError}\n"
print "Durbin Watson Test: #{durbinWatson}\n"
print "Sigma: #{sigma}\n"
print "t Stat Intercept: #{tStatIntercept}  t Stat Slope: #{tStatSlope}\n\n"
print "Predicted Ys: #{predictedYs.inspect}\n\n"
print "Residuals: #{residuals.inspect}\n\n"
print "Variance Intercept: #{varianceIntercept}   Variance Slope: #{varianceSlope}\n"
print "\n"

newX = 24
newY = lineFit.forecast(newX)
print "New X: #{newX}\nNew Y: #{newY}\n"