---
layout: post
asset-type: post
title: "Dunbar's number deconstructed (again)"
description: When linear regression is taken too far.
date: 2024-09-17 08:30:00 +02:00
category: 
author: John Hearn
tags: science

---

[Last week](dunbars-number-good-science-within-limits) I was looking at how Dunbar arrived at his famous number and learnt a lot about the effects of different types of linear regression and the limits of their predictive power. I concluded that, while the science was good, the wide error margin in the linear regression over log transformed data means that we need to apply a good deal of caution about arriving at any specific number.

The data I used was from one of his more recent papers{% sidenote "dunbar-2021" "Dunbar, Robin I. M., and Susanne Shultz. ‘Social Complexity and the Fractal Structure of Group Size in Primate Social Evolution’. Biological Reviews 96, no. 5 (October 2021): 1889–1906. [doi.org/10.1111/brv.12730](https://doi.org/10.1111/brv.12730)." %} so my results were slightly different from his. It was tabulated in the paper and I was just too lazy to copy it out. Nevertheless I was left with some curiosity about how the results might have changed using the original data. 

## Reproducing Dunbar's exact results

So yesterday, with a combination of OCR and careful copying, I recovered Dunbar's original data from his paper. Here's a reproduction of a plot of the data - satisfyingly similar to the original.

{% marginfigure dunbars-data "assets/images/dunbar/dunbars data.png" "Comparison with Dunbar's data taken from his original paper." %}

<br/>
{% maincolumn "assets/images/dunbar/dunbars data original.png" "Figure 1. Mean group size for individual genera plotted against neocortex ratio (relative to rest of brain; i.e., total brain volume less neocortex). (●) Polygamous anthropoids; (+) monogamous anthropoids; (○) diurnal prosimians; (□) nocturnal prosimians; (△) hominoids." %}

Not sure why those axis limits were chosen, maybe just rounding to orders of ten. In any case group sizes less than 1 make no sense and neocortex ratios beyond that of humans are not useful. From now on the plots will focus on the meaningful ranges. They'll also have the vertical axis on the right so that predicted values are easier to read off.

To this graph Dunbar's original fit is overlaid. One again his famous number, 150, appears as the predicted value for human group size.

{% maincolumn "assets/images/dunbar/dunbars result original.png" "Figure 2: Same plot restricting the axes to a meaningful range and extending Dunbar's fit to the measured neocortex ratio for humans (4.102)." %}

Using this data and using exactly the same RMA (aka Geometric) linear regression we can recover his results almost{% sidenote "almost" "I believe there are some minor transcription errors in the original paper (or my reading of it) which produce a very slightly different line but the difference is minimal and changes nothing." %} exactly. The next plot shows the agreement along with the 95% confidence interval as calculated following Rayner{% sidenote "rayner-1985" "Rayner, J. M. V. ‘Linear Relations in Biomechanics: The Statistics of Scaling Functions’. Journal of Zoology 206, no. 3 (July 1985): 415–39. [10.1111/j.1469-7998.1985.tb05668.x](https://doi.org/10.1111/j.1469-7998.1985.tb05668.x)." %}.

{% maincolumn "assets/images/dunbar/my result original.png" "Figure 3: plot extending the 95% confidence interval of the geometric mean regression out to the measured neocortex ratio for humans (4.102), confirming agreement with Dunbar's original results." %}

This agreement was exactly what I was hoping for by using the original data and reproduces Dunbar's result satisfactorily.

## Residuals

One again we can apply simple residual checks on the data to ensure we are satisfying the linear regression assumptions. The [qqplot](https://en.wikipedia.org/wiki/Q%E2%80%93Q_plot) shows the residuals close to a normal distribution.

{% maincolumn "assets/images/dunbar/residuals distribution original.png" "Figure 4: Q-Q plot comparing the standardised residuals with a standard normal distribution." %}

The residuals plot itself shows some variance but no obvious [heteroscedasticity](https://en.wikipedia.org/wiki/Homoscedasticity_and_heteroscedasticity).

{% maincolumn "assets/images/dunbar/residuals plot original.png" "Figure 5: Plot of the residuals." %}

## Confidence in the mean

While the fit itself is statistically sound, if we look again at Figure 3, we can see that the logarithmic scale underplays the numerical range. Looking at the same graph with the vertical axis scaled linearly then the problem is clear.

{% maincolumn "assets/images/dunbar/predict original.png" "Figure 6: plot extending the 95% confidence interval of the geometric mean regression out to the measured neocortex ratio for humans (4.102)." %}

The confidence interval (which is *only for the mean itself*) is from under 100 to nearly 250. This is worse than the previous data because the slope is greater. I think you will agree that this is a wide error margin which is partially obscured by the log-log view. If we don't believe the confidence interval calculation (and we shouldn't, some doubt has been placed on it{% sidenote "dunbar-2021" "Changyong Feng, Hongyue Wang, Naiji Lu, Tian Chen, Hua He, Ying Lü, and Xin Tu. ‘Log-Transformation and Its Implications for Data Analysis’. Shanghai Archives of Psychiatry 26, no. 2 (1 April 2014): 105–9. [10.3969/j.issn.1002-0829.2014.02.009](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4120293/)." %}, see below) then let's take a different approach and compare.

Assuming the parameters of the fit are normal, *as we must because it was an assumption of the regression itself and has been somewhat confirmed empirically*, then we can generate random samples of regression lines drawn from those distributions. This is a so-called Monte-Carlo simulation of the regression distributions and gives us an alternative way to histogram the predicted values. The following plot shows 3000 such samples together with a histogram of the predicted values for human group size.

{% maincolumn "assets/images/dunbar/ncr vs gs mc.png" "Figure 7: plot of Monte Carlo random samples of the regression line together with a histogram of the predicted value for human group size." %}

Again we find an average in the right range (see below) but once more with very wide error margins for the prediction. Actually it's worse. The distribution is clearly heavy tailed towards higher group sizes. This is an expected effect of converting a Normal distribution on a log scale to a linear scale where it becomes Log Normal and therefore long tailed. Taking 1 million such predictions it's evident that it conforms very closely.

{% maincolumn "assets/images/dunbar/prediction histogram.png" "Figure 8: histogram of 1 million predictions fitting very closely with a LogNormal distribution. 95% quantiles are shown as vertical lines at 71 and 368 respectively. Mean is 176." %}

Taking these results we can confirm that the 95% confidence interval has widened further, from 71 as a lower bound to 368 as the upper. Remember that this is still the range for the mean itself and does not take into account the variability in the samples.

There is another insight here too. The mean of the LogNormal distribution is **not 150 but rather 176**. The reason for this is exactly as stated in [Feng et al.](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4120293/) and can be confirmed by direct calculation. The mean of the distribution when transformed back into natural units is *not* $exp(\mu) = 150$ but rather $exp(\mu + \sigma^2/2) = 176$. The variance shifts the mean.

# Confidence in the prediction

We've stated several times that until now we have been looking at inferences related only to the prediction of the mean of the regression line, not including the variance in the data itself. Let's take that into account now. We know the variance in the residuals and under the assumption they are normally distributed in log space then, in principle, we can model the residuals in the predicted value. 

The normal distribution of the mean regression and the normal distribution of the residuals is combined using the relation: $𝒩(\mu_1, \sigma_1^2)+𝒩(\mu_2,\sigma_2^2) = 𝒩(\mu_1+\mu_2, \sigma_1^2+\sigma_2^2)$. We can then carefully extend this to linear space by expressing as a *Lognormal* distribution with parameters $\mu = ln(10)(\mu_1+\mu_2)$ and $\sigma = ln(10)\sqrt{\sigma_1^2+\sigma_2^2}$. {% marginnote "ln10" "The $ln(10)$ factors are necessary because the original data was transformed base 10 and the relation between the normal and the Lognormal is via the natural logarithm." %}

Using this new distribution the confidence interval has now widened still further. The 95% interval ranging between 31 to over 740. The mean now is above 200 due to the upward effect of the increased variance.

# Conclusion

With the original data it's been possible to reproduce Dunbar's famous results almost perfectly. 

However it has become even clearer that the extrapolation of the regression line to human scales is highly questionable. The prediction is well outside the existing data, leading to wide error margins, and the log transformation exaggerates the error still further. If we also take into account the residual variance in the data, the confidence interval of any prediction widens beyond useful limits (according to my analysis, the 95% interval is from 71 up to 740).

This is not an issue related to the type of regression nor any internal structure in the samples but rather the overwhelming error margins that make sensible prediction based on the available data unreasonable.

This is all consistent with the Stockholm University group's "deconstruction"{% sidenote "Lindenfors-2021" "Patrik Lindenfors, Patrik Lindenfors, Andreas Wartel, Andreas Wartel, Johan Lind, and Johan Lind. ‘“Dunbar’s Number” Deconstructed’. Biology Letters 17, no. 5 (1 May 2021): 20210158–20210158. [10.1098/rsbl.2021.0158](https://doi.org/10.1098/rsbl.2021.0158)." %} of not only the number itself, but the notion that such a number is even sensible to talk about.  

