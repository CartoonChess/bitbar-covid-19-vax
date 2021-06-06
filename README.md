# COVID-19 Vax for BitBar
Displays percentage of people vaccinated against COVID-19 for a given country in your macOS menu bar

## Installation
1. Make sure you're using macOS.
2. Install `jq` from the [jq homepage](https://stedolan.github.io/jq/download/) or via [homebrew](https://brew.sh) with `brew install jq`.
3. Install [BitBar](https://github.com/matryer/bitbar).
4. Download the [plugin](https://github.com/CartoonChess/bitbar-covid-19-vax/blob/master/covid-19_vax.15m.sh) and install it using the [BitBar instructions](https://github.com/matryer/bitbar#installing-plugins).
  - Make sure the path to your plugins doesn't contain any single or quotation marks. Ideally, avoid spaces as well.
5. Open the plugin in a text editor and change the `COUNTRY` to a two- or three-letter country code.
6. Refresh BitBar via its built-in menu. If everything is set up correctly, you should briefly see a **…** icon, and then the number of people vaccinated against COVID-19.

![COVID-19 Vax plugin sample](https://user-images.githubusercontent.com/43363630/120919718-01d62d00-c6f6-11eb-902a-45edddcda334.png)

## Attributions
In addition to the projects mentioned above, this plugin owes great thanks to the original upon which it is heavily based, [covid-bitbar](https://github.com/wilsongoode/covid-bitbar) by Wilson Goode.
Thanks as well to [disease.sh](https://disease.sh) and [Our World In Data](https://ourworldindata.org) for the data, as well as everyone doing their part.
