#!/bin/bash

# <bitbar.title>COVID-19 Vaccinations</bitbar.title>
# <bitbar.version>v1.1.0</bitbar.version>
# <bitbar.author>CartoonChess</bitbar.author>
# <bitbar.author.github>cartoonchess</bitbar.author.github>
# <bitbar.desc>Displays percentage of people vaccinated against COVID-19 for a given country.</bitbar.desc>
# <bitbar.image>https://user-images.githubusercontent.com/43363630/120919718-01d62d00-c6f6-11eb-902a-45edddcda334.png</bitbar.image>
# <bitbar.dependencies>bash,jq</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/CartoonChess/bitbar-covid-19-vax</bitbar.abouturl>

# ==============================CONFIGURATION================================
# The country must be a two- or three-letter country code.
COUNTRY="kr"
# Show the number of fully vaccinated people, otherwise anyone with at least one shot.
SHOW_FULLY_VACCINATED=false
# Include emoji in menu bar.
USE_EMOJI=true
# ===========================================================================



# ==============================DEPENDENCIES=================================
# This script requires jq for manipulating JSON data.
# Requires: https://stedolan.github.io/jq/
# Install via brew:  `brew install jq`
# ===========================================================================

# ===============================DATA SOURCE=================================
# This script curls JSON data from disease.sh, the Open Disease API:
# https://disease.sh/
# GitHub: https://github.com/disease-sh/api
#
# As well as from Our World In Data by way of GitHub:
# https://ourworldindata.org/
# GitHub: https://github.com/owid/covid-19-data
# ===========================================================================

# ================================PRIOR ART==================================
# This script is a modified version of:
# covid-bitbar
# https://github.com/wilsongoode/covid-bitbar
# by Wilson Good
# Check there for a version with detailed stats for the US.
# Many thanks!
# ===========================================================================



# Setting my Bitbar path to include /usr/local/bin. Systems may vary
# jq fails without this
PATH=/usr/local/bin:${PATH}
export PATH
LANG=en_US.UTF-8 # needed in BitBar env for awk to format numbers
export LANG



# Test for jq

JSON_PARSER="jq"
if [ ! $(command -v $JSON_PARSER) ]; then
    echo "⚠"
    echo "---"
    echo "$JSON_PARSER Not Installed"
    echo "Install ${JSON_PARSER}… | href=https://stedolan.github.io/${JSON_PARSER}/download/"
    echo "---"
    echo "Refresh | refresh=true"
    exit
fi



# Methods

# Return number with comma as thousands place separator
# Usage:
# BIG_NUM=1500
# echo "I have $(commas $BIG_NUM) bees"
# Output: I have 1,500 bees
commas() {
    echo $(awk 'BEGIN{printf "%\047d\n", '$1'}')
}

# Round a number to the nearest integer
# Usage:
# SCORE=73.4
# echo "I scored approximately $(round $SCORE) on the test"
# Output: I scored approximately 73 on the test"
round() {
    NUMBER=$1
    echo $NUMBER | awk '{print int($1+0.5)}'
}



# Get the three-letter country code and country name

COUNTRY_DATA=$(curl -s https://disease.sh/v3/covid-19/countries/$COUNTRY)

# Maybe the server is down?
if [ -z "$COUNTRY_DATA" ]; then
    echo "⚠"
    echo "---"
    echo "No Information"
    echo "Refresh | refresh=true"
    exit
fi

COUNTRY_CODE=$(echo $COUNTRY_DATA |
    jq '.countryInfo.iso3' |
    sed -E 's/"//g'
    )
COUNTRY_NAME=$(echo $COUNTRY_DATA |
    jq '.country' |
    sed -E 's/"//g'
    )

# If there's no country code, there's a problem with the data
# jq returns a literal string "null", NOT a null value
if [ $COUNTRY_CODE = "null" ]; then
    echo "⚠"
    echo "---"
    echo "Invalid Country Code"
    echo "Use a two- or three-letter code in the script"
    echo "Open Plugin Folder… | href=file://${0%/*}/"
    echo "---"
    echo "Refresh | refresh=true"
    exit
fi

    

# Fetch vaccination numbers
VACCINATIONS_DATA=$(curl -s https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.json)

VACCINATED_PERCENT=$(echo $VACCINATIONS_DATA |
    jq --arg country_code $COUNTRY_CODE \
    '.[] | select(.iso_code == $country_code) | .data |
    .[-1].people_vaccinated_per_hundred'
    )

FULLY_VACCINATED_PERCENT=$(echo $VACCINATIONS_DATA |
    jq --arg country_code $COUNTRY_CODE \
    '.[] | select(.iso_code == $country_code) | .data |
    .[-1].people_fully_vaccinated_per_hundred'
    )

VACCINATIONS_TODAY=$(echo $VACCINATIONS_DATA |
    jq --arg country_code $COUNTRY_CODE \
    '.[] | select(.iso_code == $country_code) | .data |
    .[-1].daily_vaccinations'
    )

MOST_RECENT_DATE=$(echo $VACCINATIONS_DATA |
    jq --arg country_code $COUNTRY_CODE \
    '.[] | select(.iso_code == $country_code) | .data |
    .[-1].date' |
    sed -E 's/"//g'
    )

   
   
    
# Show menu bar item

# Choose main data point and round percentage
if [ $SHOW_FULLY_VACCINATED = true ]; then
    ICON=$(round $FULLY_VACCINATED_PERCENT)
else
    ICON=$(round $VACCINATED_PERCENT)
fi

if [ $USE_EMOJI = true ]; then
    ICON="💉$ICON"
fi

echo "$ICON%"
echo "---"



# Show dropdown details

# Partially vaccinated
echo "$VACCINATED_PERCENT% of people vaccinated in $COUNTRY_NAME | href=https://ourworldindata.org/explorers/coronavirus-data-explorer?Metric=People+vaccinated&Relative+to+Population=true&country=$COUNTRY_CODE"

# Fully vaccinated
echo "$FULLY_VACCINATED_PERCENT% of people fully vaccinated in $COUNTRY_NAME | href=https://ourworldindata.org/explorers/coronavirus-data-explorer?Metric=People+fully+vaccinated&Relative+to+Population=true&country=$COUNTRY_CODE"

# Today's stats
VACCINATIONS_TODAY_FORMATTED=$(commas $VACCINATIONS_TODAY)
# Mac-specific formatting; Linux would require a change
DATE_FORMATTED=$(date -j -f "%Y-%m-%d" $MOST_RECENT_DATE +"%B %-d")
echo "$VACCINATIONS_TODAY_FORMATTED vaccinations newly administered on $DATE_FORMATTED"


# Options

echo "---"
echo "Update | refresh=true"
echo "Settings"
echo "-- Edit the plugin directly to change the country"
echo "-----"
echo "-- Open Plugin Folder… | href=file://${0%/*}/"
