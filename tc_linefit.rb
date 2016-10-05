require_relative "lib/linefit"
require "test/unit"

class TestLineFit < Test::Unit::TestCase

    def setup
        @lineFit = LineFit.new
    end

    def test_basic_example
        x = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
        y = [4039,4057,4052,4094,4104,4110,4154,4161,4186,4195,4229,4244,4242,4283,4322,4333,4368,4389]
        @lineFit.setData(x, y)
        intercept, slope = @lineFit.coefficients
        rSquared = @lineFit.rSquared
        meanSquaredError = @lineFit.meanSqError
        durbinWatson = @lineFit.durbinWatson
        sigma = @lineFit.sigma
        tStatIntercept, tStatSlope = @lineFit.tStatistics
        predictedYs = @lineFit.predictedYs
        residuals = @lineFit.residuals
        varianceIntercept, varianceSlope = @lineFit.varianceOfEstimates

        assert_equal(4002.0653594771243, intercept, 'Intercept calc error')
        assert_equal(20.613003095975234, slope, 'Slope calc error')
        assert_equal(0.9871028869331805, rSquared, 'rSquared calc error')
        assert_equal(149.42865879368685, meanSquaredError, 'Mean Squared Error calc error')
        assert_equal(1.5273464901323115, durbinWatson, 'Durbin Watson calc error')
        assert_equal(12.965617653737045, sigma, 'Sigma calc error')
        assert_equal(627.6764289396855, tStatIntercept, 't Stat Intercept calc error')
        assert_equal(34.99410968577564, tStatSlope, 't Stat Slope calc error')

        correct_predicted_ys = [
            4022.6783625730995,
            4043.291365669075,
            4063.90436876505,
            4084.5173718610254,
            4105.130374957001,
            4125.7433780529755,
            4146.356381148951,
            4166.969384244926,
            4187.582387340902,
            4208.195390436877,
            4228.808393532852,
            4249.421396628827,
            4270.034399724802,
            4290.647402820778,
            4311.2604059167525,
            4331.873409012728,
            4352.486412108703,
            4373.099415204679]
        assert_equal(correct_predicted_ys, predictedYs, 'Predicted Ys calc error')

        correct_residuals = [
            16.321637426900452,
            13.708634330925179,
            -11.904368765050094,
            9.482628138974633,
            -1.1303749570006403,
            -15.743378052975459,
            7.643618851048814,
            -5.969384244926005,
            -1.5823873409017324,
            -13.19539043687655,
            0.19160646714772156,
            -5.421396628827097,
            -28.034399724801915,
            -7.647402820777643,
            10.739594083247539,
            1.1265909872718112,
            15.513587891296993,
            15.900584795321265]
        assert_equal(correct_residuals, residuals, 'Residuals calc error')

        assert_equal(2.3146946263794774, varianceIntercept, 'Variance Intercept calc error')
        assert_equal(0.01905749720682022, varianceSlope, 'Variance Slope calc error')

        newX = 24
        newY = @lineFit.forecast(newX)
        assert_equal(4496.7774337805295, newY, 'Linefit forecast failed')
    end

    def test_weighted_example
        x = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
        y = [4039,4057,4052,4094,4104,4110,4154,4161,4186,4195,4229,4244,4242,4283,4322,4333,4368,4389]
        weights = [5,10,0,5,10,10,20,5,0,10,5,5,5,10,20,0,5,10]
        @lineFit.setData(x, y, weights)
        intercept, slope = @lineFit.coefficients
        rSquared = @lineFit.rSquared
        meanSquaredError = @lineFit.meanSqError
        durbinWatson = @lineFit.durbinWatson
        sigma = @lineFit.sigma
        tStatIntercept, tStatSlope = @lineFit.tStatistics
        predictedYs = @lineFit.predictedYs
        residuals = @lineFit.residuals
        varianceIntercept, varianceSlope = @lineFit.varianceOfEstimates

        assert_equal(4003.280090351728, intercept, 'Intercept calc error')
        assert_equal(20.713778638270224, slope, 'Slope calc error')
        assert_equal(0.9871368644064613, rSquared, 'rSquared calc error')
        assert_equal(142.60456777917958, meanSquaredError, 'Mean Squared Error calc error')
        assert_equal(1.600535293064521, durbinWatson, 'Durbin Watson calc error')
        assert_equal(12.666101955675908, sigma, 'Sigma calc error')
        assert_equal(615.3750790554614, tStatIntercept, 't Stat Intercept calc error')
        assert_equal(35.04090005949416, tStatSlope, 't Stat Slope calc error')

        correct_predicted_ys = [
            4023.993868989998,
            4044.7076476282687,
            4065.4214262665387,
            4086.135204904809,
            4106.848983543079,
            4127.562762181349,
            4148.27654081962,
            4168.99031945789,
            4189.70409809616,
            4210.41787673443,
            4231.131655372701,
            4251.845434010971,
            4272.559212649241,
            4293.272991287511,
            4313.986769925781,
            4334.700548564052,
            4355.414327202322,
            4376.128105840592]
        assert_equal(correct_predicted_ys, predictedYs, 'Predicted Ys calc error')

        correct_residuals = [
            15.006131010001809,
            12.29235237173134,
            -13.421426266538674,
            7.864795095190857,
            -2.8489835430791572,
            -17.56276218134917,
            5.723459180379905,
            -7.990319457890109,
            -3.7040980961601235,
            -15.417876734430138,
            -2.1316553727010614,
            -7.845434010971076,
            -30.55921264924109,
            -10.272991287511104,
            8.013230074218882,
            -1.700548564052042,
            12.585672797677944,
            12.87189415940793]
        assert_equal(correct_residuals, residuals, 'Residuals calc error')

        assert_equal(2.1157840392583114, varianceIntercept, 'Variance Intercept calc error')
        assert_equal(0.04268092032760079, varianceSlope, 'Variance Slope calc error')

        newX = 24
        newY = @lineFit.forecast(newX)
        assert_equal(4500.410777670213, newY, 'Linefit forecast failed')
    end

    def test_basic_example_with_array_of_arrays
        xy = [
            [ 1, 4039],
            [ 2, 4057],
            [ 3, 4052],
            [ 4, 4094],
            [ 5, 4104],
            [ 6, 4110],
            [ 7, 4154],
            [ 8, 4161],
            [ 9, 4186],
            [10, 4195],
            [11, 4229],
            [12, 4244],
            [13, 4242],
            [14, 4283],
            [15, 4322],
            [16, 4333],
            [17, 4368],
            [18, 4389] ]
        @lineFit.setData(xy)
        intercept, slope = @lineFit.coefficients
        rSquared = @lineFit.rSquared
        meanSquaredError = @lineFit.meanSqError
        durbinWatson = @lineFit.durbinWatson
        sigma = @lineFit.sigma
        tStatIntercept, tStatSlope = @lineFit.tStatistics
        predictedYs = @lineFit.predictedYs
        residuals = @lineFit.residuals
        varianceIntercept, varianceSlope = @lineFit.varianceOfEstimates

        assert_equal(4002.0653594771243, intercept, 'Intercept calc error')
        assert_equal(20.613003095975234, slope, 'Slope calc error')
        assert_equal(0.9871028869331805, rSquared, 'rSquared calc error')
        assert_equal(149.42865879368685, meanSquaredError, 'Mean Squared Error calc error')
        assert_equal(1.5273464901323115, durbinWatson, 'Durbin Watson calc error')
        assert_equal(12.965617653737045, sigma, 'Sigma calc error')
        assert_equal(627.6764289396855, tStatIntercept, 't Stat Intercept calc error')
        assert_equal(34.99410968577564, tStatSlope, 't Stat Slope calc error')

        correct_predicted_ys = [
            4022.6783625730995,
            4043.291365669075,
            4063.90436876505,
            4084.5173718610254,
            4105.130374957001,
            4125.7433780529755,
            4146.356381148951,
            4166.969384244926,
            4187.582387340902,
            4208.195390436877,
            4228.808393532852,
            4249.421396628827,
            4270.034399724802,
            4290.647402820778,
            4311.2604059167525,
            4331.873409012728,
            4352.486412108703,
            4373.099415204679]
        assert_equal(correct_predicted_ys, predictedYs, 'Predicted Ys calc error')

        correct_residuals = [
            16.321637426900452,
            13.708634330925179,
            -11.904368765050094,
            9.482628138974633,
            -1.1303749570006403,
            -15.743378052975459,
            7.643618851048814,
            -5.969384244926005,
            -1.5823873409017324,
            -13.19539043687655,
            0.19160646714772156,
            -5.421396628827097,
            -28.034399724801915,
            -7.647402820777643,
            10.739594083247539,
            1.1265909872718112,
            15.513587891296993,
            15.900584795321265]
        assert_equal(correct_residuals, residuals, 'Residuals calc error')

        assert_equal(2.3146946263794774, varianceIntercept, 'Variance Intercept calc error')
        assert_equal(0.01905749720682022, varianceSlope, 'Variance Slope calc error')

        newX = 24
        newY = @lineFit.forecast(newX)
        assert_equal(4496.7774337805295, newY, 'Linefit forecast failed')
    end

    def test_array_of_arrays_with_weighted_example
        xy = [
            [ 1, 4039],
            [ 2, 4057],
            [ 3, 4052],
            [ 4, 4094],
            [ 5, 4104],
            [ 6, 4110],
            [ 7, 4154],
            [ 8, 4161],
            [ 9, 4186],
            [10, 4195],
            [11, 4229],
            [12, 4244],
            [13, 4242],
            [14, 4283],
            [15, 4322],
            [16, 4333],
            [17, 4368],
            [18, 4389] ]
        weights = [5,10,0,5,10,10,20,5,0,10,5,5,5,10,20,0,5,10]
        @lineFit.setData(xy, weights)
        intercept, slope = @lineFit.coefficients
        rSquared = @lineFit.rSquared
        meanSquaredError = @lineFit.meanSqError
        durbinWatson = @lineFit.durbinWatson
        sigma = @lineFit.sigma
        tStatIntercept, tStatSlope = @lineFit.tStatistics
        predictedYs = @lineFit.predictedYs
        residuals = @lineFit.residuals
        varianceIntercept, varianceSlope = @lineFit.varianceOfEstimates

        assert_equal(4003.280090351728, intercept, 'Intercept calc error')
        assert_equal(20.713778638270224, slope, 'Slope calc error')
        assert_equal(0.9871368644064613, rSquared, 'rSquared calc error')
        assert_equal(142.60456777917958, meanSquaredError, 'Mean Squared Error calc error')
        assert_equal(1.600535293064521, durbinWatson, 'Durbin Watson calc error')
        assert_equal(12.666101955675908, sigma, 'Sigma calc error')
        assert_equal(615.3750790554614, tStatIntercept, 't Stat Intercept calc error')
        assert_equal(35.04090005949416, tStatSlope, 't Stat Slope calc error')

        correct_predicted_ys = [
            4023.993868989998,
            4044.7076476282687,
            4065.4214262665387,
            4086.135204904809,
            4106.848983543079,
            4127.562762181349,
            4148.27654081962,
            4168.99031945789,
            4189.70409809616,
            4210.41787673443,
            4231.131655372701,
            4251.845434010971,
            4272.559212649241,
            4293.272991287511,
            4313.986769925781,
            4334.700548564052,
            4355.414327202322,
            4376.128105840592]
        assert_equal(correct_predicted_ys, predictedYs, 'Predicted Ys calc error')

        correct_residuals = [
            15.006131010001809,
            12.29235237173134,
            -13.421426266538674,
            7.864795095190857,
            -2.8489835430791572,
            -17.56276218134917,
            5.723459180379905,
            -7.990319457890109,
            -3.7040980961601235,
            -15.417876734430138,
            -2.1316553727010614,
            -7.845434010971076,
            -30.55921264924109,
            -10.272991287511104,
            8.013230074218882,
            -1.700548564052042,
            12.585672797677944,
            12.87189415940793]
        assert_equal(correct_residuals, residuals, 'Residuals calc error')

        assert_equal(2.1157840392583114, varianceIntercept, 'Variance Intercept calc error')
        assert_equal(0.04268092032760079, varianceSlope, 'Variance Slope calc error')

        newX = 24
        newY = @lineFit.forecast(newX)
        assert_equal(4500.410777670213, newY, 'Linefit forecast failed')
    end
end
