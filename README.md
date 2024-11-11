# Gabe Sekeres' Academic Website

This repository contains the source code for [Gabe Sekeres' academic website](https://gabesekeres.com), built using the [Minimalist Hugo Template for Academic Websites](https://github.com/pmichaillat/hugo-website). The vast majority of the code is from [Pascal Michaillat](https://pascalmichaillat.org/), to whom I am very grateful. 

## Documentation

The Hugo template is documented at https://pascalmichaillat.org/d5/.

## Software

The website was built with Hugo v0.138.0 on an Apple Silicon MacBook Pro running macOS Sonoma 14.6.1. The website was tested and validated on Google Chrome Version 130.0.6723.92 and Safari 18.0.1 on a Mac and on Safari on an iPhone with iOS 18.1.

This website was built using the [Cursor IDE](https://www.cursor.com/). Necessarily, there are suggestions from LLMs (specifically, GPT-4o and Claude 3.5 Sonnet-20241022), which are built from other's code. I do not claim ownership of anything here except for the content on the website and the coding mistakes I made.

## CV

My CV is available [here](cv/gabe_sekeres_cv.pdf), and the TeX source is available [here](cv/gabe_sekeres_cv.tex). I stole and modified a template from [Zahra Thabet](https://zahrathabet.com/), to whom I am very grateful. I modified the template to compile correctly in [Texifier](https://www.texifier.com/) using [MacTeX](https://www.tug.org/mactex/) (TeX Live 2024 with kpathsea version 6.4.0). This involved downloading specific icons from [Font Awesome](https://fontawesome.com/) and converting them to png files -- a better coder can probably figure out how to get `fontawesome5` to work in Texifier, but I couldn't figure it out.


## Performance

I benchmarked the performance of the website on [PageSpeed Insights](https://pagespeed.web.dev/) on 11.11.24. Here are the results for mobile:

<img width="470" alt="mobile" src="/pagespeed_mobile.png">

And here are the results for desktop:

<img width="470" alt="desktop" src="pagespeed_desktop.png">