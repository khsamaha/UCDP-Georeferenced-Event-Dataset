---
title: "Exploratory Analysis-1"
author: "Kheirallah Samaha"
date: "September 12, 2017"
output:
  html_document:
    code_folding: hide
    fig_caption: yes
    highlight: tango
    number_sections: yes
    theme: cosmo
    toc: yes
  pdf_document:
    toc: yes
editor_options: 
  chunk_output_type: console
---


```{r setup, include=FALSE}

knitr::opts_chunk$set(echo = TRUE)

```

#### INTRODUCTION

UCDP Georeferenced Event Dataset Context The basic unit of analysis for the UCDP GED dataset is the “event”, i.e. an individual incident (phenomenon) of lethal violence occurring at a given time and place. This version authored by: Mihai Croicu, Ralph Sundberg, Ph. D.
This is a preliminary exploratory analysis.
Questions:

- what variable we going to using in terms of the number of deaths?

We are going to use the variable "best" because it is simply the sum of deaths_a,                              deaths_b, deaths_civilians and deaths_ uknown,so we are not going to separate the deaths in this kernel, 

However, if you guys think that i should take "low" or "high"", so i'm open to do so..

- The number of deaths per country using the deaths's mean of each country.
- The trend of the number of deaths from 1989 to 2016 using the deaths's mean 
- What's happened in 1994?
- The number of deaths per year (deaths_a, deaths_b, deaths_civilians and deaths_ uknown)
- The number of deaths per year (deaths_a, deaths_b, deaths_civilians and deaths_ uknown) NO 1994.
- What about one-day Event Duration?   

before we start let have an explanation regarding the variables (best,low,high), the following descriptions are according to the UCDP Codebook uploaded with Dataset.   
 
- a low estimate, containing the most conservative estimate of deaths that is identified in the source material; 
- a best estimate, containing the most reliable estimate of deaths identified in the source material; 
- a high estimate, containing the highest reliable estimate of deaths identified in the source material.

Note that UCDP attempts to distinguish and not include unreasonable claims in the high estimate of fatalities, 
and tends to be highly conservative when counting fatalities1.

In order for an event to exist, at least one dead needs to be registered in the high, best or low estimate.)

This dataset is great for exploratory analysis, for example and according to this dataset the number of deaths from 1989 to 2016 **(excluding Syria)** is about 2mln.

sum(ged$best) = 1,958,895

sum(ged$low)  = 1,555,442

sum(ged$high) = 2,906,495

OK let's start!
#### Libraries

- tidyverse
- lubridate
- reshape2
- ggplot2
- ggthemes
- gridExtra
- formatR
- scales

```{r include=TRUE, warning=FALSE, message=FALSE ,echo=FALSE}
warn.conflicts = FALSE
suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))
suppressMessages(library(reshape2))
suppressMessages(library(ggplot2))
suppressMessages(library(ggthemes))
suppressMessages(library(gridExtra))
suppressMessages(library(scales))


```

```{r import Data}
ged<-read_csv("ged201.csv")
sapply(ged,class)

sum(ged$best)
sum(ged$low)
sum(ged$high)

```
#### Theme

- let's create a special theme for this kernel, hope you will like it

```{r}
ged.theme <- theme(
                    axis.text = element_text(size = 9),
                    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
                    axis.title = element_text(size = 10),
                    panel.grid.major = element_line(color = "grey"),
                    panel.grid.minor = element_blank(),
                    panel.background = element_rect(fill = "azure2"),
                    legend.position = "right",
                    legend.justification = "top", 
                    legend.background = element_blank(),
                    panel.border = element_rect(color = "black", fill = NA, size = 1)
                    )

```

#### Zero Deaths !!

As mentioned in codebook "In order for an event to exist, at least one dead needs to be registered in the high, best or low estimate."

Ok let's see it:

```{r}

nrow(ged[ged$best == 0 &ged$low==0 & ged$high==0 , ])

```
0 rows!...Yes indeed at least one dead needs to be registered in the high, best or low estimate.

Here appears the need of another variables drive the best high and low , as following:
 
**A- number_of_sources:** 
Number of total sources containing information for an event that were consulted.
 
- Note that this variable is only available for data collected for 2013 - 2016, and for recently revised events. 
                                                
-  For older data, -1. Note that -1 does NOT mean information on the source is missing;reference to the source material is ALWAYS available in the source_article field. 

  **B- where_prec:** The precision with which the coordinates and location assigned to the event reflects the location of the actual event.
  
- 1: exact location of the event known and coded.

- 2: event occurred within at maximum a ca. 25 km radius around a known point. The coded point is the known point.

- 3: only the second order administrative division where an event happened is known. That administrative division is coded with a point representing it (typically the centroid).

- 4: only the first order administrative division where an event happened is known. That administrative division is coded with a point representing it (typically the centroid).

- 5: the only spatial reference for the event is neither a known point nor a known formal administrative division, but rather a linear feature (e.g. a long river, a border, a longer road or the line connecting two locations further afield than 25 km) or a fuzzy polygon without defined borders (informal regions, large radiuses etc.). A representation point is chosen for the feature and employed. 
                 
- 6: only the country where the event took place in is known.

- 7: event in international waters or airspace.
                 
**C- event_clarity:**

- 1- (high) for events where the reporting allows the coder to identify the event in full. 
                      That is, events where the individual happening is described by the original source in sufficiently detailed way as to identify individual incidents, i.e. separate activities of fighting in a single location:  Example of such reporting: (2 people where killed in Banda Aceh town on the 9th of December in fighting between the government and GAM when a car exploded in a main market.)
                      
- 2- (lower) for events where an aggregation of information was already made by the source material that is impossible to undo in the coding process. Such events are described by the original source only as aggregates (totals) of multiple separate activities of fighting spanning over a longer period than a single, clearly defined day. Examples of such reporting: "The Ukrainian government informs that 29 people have died in the past six days in a number of clashes with the separatists along the line of conflict".
 
**D- date_prec** : How precise the information is about the date of an event.

- 1: exact date of event is known; 
- 2: the date of the event is known only within a 2-6 day range. 
- 3: only the week of the event is known 
- 4: the date of the event is known only within an 8-30 day range or only the month when the event has taken place is known 
- 5: the date of the event is known only within a range longer than one month but not more than one calendar year. 

Let's create a new data frame based on ged$best = 0 and add a new variable as Event Duration.

```{r}
 
ged$date_start <- as.Date(ged$date_start, format = "%d-%m-%y")

ged$date_end <- as.Date(ged$date_end, format = "%d-%m-%y")

duration.even <- NULL

for (i in nrow(ged)) {
  duration.even <- ged$date_end - ged$date_start
}

ged$duration.even <- duration.even

ged$duration.even <- ged$date_end - ged$date_start

ged$duration.even[ged$duration.even == 0] <- 1

ged$duration.even <- as.numeric(ged$duration.even)

zero.deaths.best <-
  ged[ged$best == 0 , c(
    "id",
    "year",
    "dyad_name",
    "number_of_sources",
    "where_prec",
    "event_clarity",
    "date_prec",
    "deaths_a",
    "deaths_b",
    "deaths_civilians",
    "deaths_unknown",
    "best",
    "low",
    "high",
    "duration.even"
  )]

summary(zero.deaths.best[, c(9:15)])

```

WOW ... interesting, how come the (ged$best) and most reliable estimate is 0 and MAX of (ged$high) is 11000? more interesting is that the Max of event duration is 365 and the ged$best estimate is 0.

```{r}

zero.deaths.best[zero.deaths.best$high == 0,]

```
 
(62 days) and (85 days) events durations with (0) fatalities in (ged$best), and (33) & (5) fatalities in (ged$low).  

```{r}

zero.deaths.best[zero.deaths.best$high == 11000,]
 
```
One-day duration with fatalities of 11000 and 0 in both (ged$best) and (ged$low) ...we have to check the resources and other staff. 

```{r}

zero.deaths.best[zero.deaths.best$duration.even > 364,]
 
nrow(zero.deaths.best[zero.deaths.best$duration.even > 364,])
 
```

20 rows of 365 days in ged$duration.even variable and 0s fatalities in (ged$best) 

definetly; the variables:

- number_of_sources
- where_prec
- event_clarity
- date_prec

all together have a noticeable influence on the deaths variables.

for now ill go with simple exploratory analysis.

#### Region

I'm very interesting to see the Total of Deaths, of course using the variable `best`, based on Regions

```{r}

levels(ged$region)

```

Note : I will take the range between 50 and 1000 deaths for plotting purpose, in any the result will remain the same as summarized by the first pipe.

```{r}

ged %>% select(year, region, best) %>%
  group_by(region) %>%
  summarise(total = sum(best)) %>%
  arrange(total)

ged %>%
  filter(between(best, 50, 1000) & between(year, 1989, 2016)) %>%
  ggplot(aes(x = as.factor(year), y = best)) +
  geom_boxplot() +
  facet_wrap( ~ region) +
  ged.theme +
  theme(
    axis.text = element_text(size = 6),
    axis.text.x = element_text(
      angle = 90,
      vjust = 0.5,
      hjust = 0.5
    )
  ) +
  scale_x_discrete(labels = wrap_format(10)) +
  ggtitle("Deaths VS Region (best estimate)") +
  labs(x = "Year",
       y = "Number of Deaths")

```

```{r}

ged %>% select(year, region, best) %>%
  filter(between(best, 50, 1000) & between(year, 1989, 2016)) %>%
  group_by(region, year) %>%
  summarise(total = sum(best)) %>%
  ggplot(aes(x = as.factor(year), y = total, col = region)) +
  geom_point() +
  facet_wrap( ~ region) +
  ged.theme +
  theme(
    axis.text = element_text(size = 6),
    axis.text.x = element_text(
      angle = 90,
      vjust = 0.5,
      hjust = 0.5
    )
  ) +
  scale_x_discrete(labels = wrap_format(10)) +
  ggtitle("Deaths VS Region (best estimate)") +
  labs(x = "Year",
       y = "Total Deaths") +
  theme(legend.position = "none")
 

```

Not surprisingly! Americas is the lowest, Africa is the highest the lower number in Africa was between 2005 - 2011...and starts trending down from 2014 to 2016...   

so far so good ...let's find out which country in Americas has the lowest number of deaths... of course regardless of the population of each country...

```{r}
americas.ged.best <- ged %>% select(region, country, best) %>%
  filter(region == "Americas" &
           best > 0) %>%
  group_by(country) %>%
  summarise(total.deaths = sum(best)) %>%
  mutate(percent = round(total.deaths / sum(total.deaths) * 100, 2))

plot.amer.best <-
  qplot(x = reorder(country, -total.deaths),
        y = total.deaths,
        data = americas.ged.best[americas.ged.best$total.deaths >
                                   600, ]) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme(
    axis.text = element_text(size = 6),
    axis.text.x = element_text(
      angle = 90,
      vjust = 0.5,
      hjust = 0.5
    )
  ) +
  ged.theme +
  geom_text(aes(
    label = total.deaths,
    hjust = 0.5,
    vjust = -0.3
  ),
  size = 3,
  color = "red") +
  ggtitle("Deaths VS Countries in Americas (Best)") +
  labs(x = "Country",
       y = "Total Deaths")


#### high

americas.ged.high <- ged %>% select(region, country, high) %>%
  filter(region == "Americas" &
           high > 0) %>%
  group_by(country) %>%
  summarise(total.deaths = sum(high)) %>%
  mutate(percent = round(total.deaths / sum(total.deaths) * 100, 2))


plot.amer.high <-
  qplot(x = reorder(country, -total.deaths),
        y = total.deaths,
        data = americas.ged.high[americas.ged.high$total.deaths >
                                   600, ]) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme(
    axis.text = element_text(size = 6),
    axis.text.x = element_text(
      angle = 90,
      vjust = 0.5,
      hjust = 0.5
    )
  ) +
  ged.theme +
  geom_text(aes(
    label = total.deaths,
    hjust = 0.5,
    vjust = -0.3
  ),
  size = 3,
  color = "red") +
  ggtitle("Deaths VS Countries in Americas (High)") +
  labs(x = "Country",
       y = "Total Deaths")


##### low

americas.ged.low <- ged %>% select(region, country, low) %>%
  filter(region == "Americas" &
           low > 0) %>%
  group_by(country) %>%
  summarise(total.deaths = sum(low)) %>%
  mutate(percent = round(total.deaths / sum(total.deaths) * 100, 2))


plot.amer.low <-
  qplot(x = reorder(country, -total.deaths),
        y = total.deaths,
        data = americas.ged.low[americas.ged.low$total.deaths >
                                  500, ]) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme(
    axis.text = element_text(size = 6),
    axis.text.x = element_text(
      angle = 90,
      vjust = 0.5,
      hjust = 0.5
    )
  ) +
  ged.theme +
  geom_text(aes(
    label = total.deaths,
    hjust = 0.5,
    vjust = -0.3
  ),
  size = 3,
  color = "red") +
  ggtitle("Deaths VS Countries in Americas (Low)") +
  labs(x = "Country",
       y = "Total Deaths")

plot.amer.best
plot.amer.high
plot.amer.low

```

OK let's go through countries across the world!

#### Country: Mean (Deaths)

```{r}
country.d.mean <- tapply(ged$best, ged$country , mean)
country.d.mean <- data.frame(country.d.mean)
country.d.mean <- rownames_to_column(data.frame(country.d.mean),
                                     "country")

names(country.d.mean) <- c(country = "country",
                           country.d.mean = "country.mean.d")

summary(country.d.mean$country.mean.d)

ggplot(country.d.mean[country.d.mean$country.mean.d > 16,],
       aes(x = country, y = country.mean.d)) +
  geom_point() +
  theme_calc() +
  theme(axis.text.x = element_text(
    size = 8,
    angle = 90,
    hjust = 0.5
  )) +
  ggtitle("Deaths (the mean by Country)") +
  labs(x = "Country",
       y = "Mean")

```
Rwanda is the TOP , remember that the events with 1 death are in for now!

let's see the deaths by year.

```{r}
year.mean <- tapply(ged$best, ged$year , mean)

year.mean <- data.frame(year.mean)

year.mean <- rownames_to_column(data.frame(year.mean),
                                "year")

names(year.mean) <- c(year = "year",
                      year.mean = "mean")


ggplot(year.mean, aes(x = as.factor(year), y = mean)) +
  geom_point() +
  ged.theme +
  theme(axis.text.x = element_text(
    size = 8,
    angle = 90,
    hjust = 0.5
  )) +
  ggtitle("Deaths (The mean by Year)") +
  labs(x = "Year",
       y = "mean")

```
1994 is the TOP 1 ...lets see why?
I will check the Summary and use the highest numbers to filter the data so to not be crowded.

```{r}
y1994 <- ged[ged$year == 1994, c(2, 8, 40)]

y1994_n <- aggregate(y1994$best ~ y1994$dyad_name, y1994, sum)

y1994_group <-
  aggregate(list(total = y1994$best) , list(dyad.name = y1994$dyad_name), sum)


summary(y1994_group$total)


```
I do not like this kind of numbers (500000) looks like someone put it as it is the Maximum, because the real number was not available.

Let's Plot it

```{r}

ggplot(y1994_group[between(y1994_group$total, 2000, 500000),], aes(x = dyad.name , y =
                                                                     total)) +
  geom_point(stat = "identity") +
  ged.theme +
  scale_x_discrete(labels = wrap_format(10)) +
  geom_text(aes(
    label = total,
    hjust = 0.5,
    vjust = 1.3
  ),
  size = 3.5,
  color = "red") +
  ggtitle("Happened in 1994?") +
  labs(x = "Dyad Name",
       y = "Total Deaths")
```
Again Rwanda let's see the Dyad name

```{r}

rwanda <- ged[ged$country == "Rwanda",]

rwanda.1994 <- rwanda[rwanda$year == 1994,]

rwanda.dyad.1994.sum <-
  aggregate(list(total = rwanda.1994$best),
            list(dyad.name = rwanda.1994$dyad_name) ,
            sum)

ggplot(rwanda.dyad.1994.sum, aes(x = dyad.name , y = total)) +
  geom_point(stat = "identity") +
  ged.theme +
  scale_x_discrete(labels = wrap_format(10)) +
  geom_text(aes(
    label = total,
    hjust = 0.5,
    vjust = 1.3
  ),
  size = 3.5,
  color = "red") +
  ggtitle("Happened in 1994 in Rwanda?") +
  labs(x = "Dyad Name",
       y = "Total Deaths")

```

Not surprisingly, Civilians! 

```{r}

rwanda.where.1994.sum <-
  aggregate(list(total = rwanda.1994$best),
            list(where = rwanda.1994$where_coordinates) ,
            sum)

rwanda.where.1994.sum <-
  rwanda.where.1994.sum[order(rwanda.where.1994.sum$total, decreasing = TRUE),]

summary(rwanda.where.1994.sum$total)

ggplot(rwanda.where.1994.sum[rwanda.where.1994.sum$total >= 5000,],
       aes(x = where , y = total)) +
  geom_point(stat = "identity") +
  ged.theme +
  scale_x_discrete(labels = wrap_format(10)) +
  geom_text(aes(
    label = total,
    hjust = 0.5,
    vjust = 1.3
  ),
  size = 3.5,
  color = "darkred") +
  ggtitle("Happened in 1994 in Rwanda (Where?)") +
  labs(x = "Where Coordinates",
       y = "Total Deaths")


```

I think they put Rwanda because they have not got the correct names of places, it mean that reporting was not effective.

So let's remove observation "Rwanda" to see the result!

```{r}

ggplot(rwanda.where.1994.sum[rwanda.where.1994.sum$where != "Rwanda" &
                               rwanda.where.1994.sum$total >= 10000 , ],
       aes(x = where , y = total)) +
  geom_point(stat = "identity") +
  ged.theme +
  scale_x_discrete(labels = wrap_format(10)) +
  geom_text(aes(
    label = total,
    hjust = 0.5,
    vjust = 1.3
  ),
  size = 3.5,
  color = "darkred") +
  ggtitle("Happened in 1994 in Rwanda (Where?)") +
  labs(x = "Where Coordinates",
       y = "Total Deaths")

```

KARAMA CHURCH, let's check and see what we can find..40000 deaths ??? 
```{r}
karama.church <- ged[ged$where_coordinates == "Karama church", ]
nrow(karama.church)
karama.church[, c(15, 21, 32, 33, 40:43)]

karama.church[, "source_article"]


```
40000 civilians were killed during 1 day; event_clarity is 1 and date_prec is 1 and of caurse where_prec is 1.
number_of_sources is -1 because the event happened before 2013...

im sure this day became unforgettable day for this area

Now, let's calculate and plot the Number of deaths by deaths_a, deaths_b, deaths_civilians and deaths_ uknown.

```{r}


deaths.a.b.c.u <- ged[ged$best > 0 , c(2, 36:40)]

deaths.a.b.c.u.group <-
  summarise(
    group_by(
      deaths.a.b.c.u,
      deaths.a.b.c.u$year,
      deaths.a.b.c.u$deaths_a,
      deaths.a.b.c.u$deaths_b,
      deaths.a.b.c.u$deaths_civilians,
      deaths.a.b.c.u$deaths_unknown,
      deaths.a.b.c.u$best
    )
  )

names(deaths.a.b.c.u.group) <- c("year",
                                 "deaths_a",
                                 "deaths_b",
                                 "deaths_civilians",
                                 "deaths_unknown",
                                 "best")

agre.death <-
  aggregate(deaths.a.b.c.u.group,
            by = list(deaths.a.b.c.u.group$year),
            FUN = sum)

agre.death <- agre.death[, c(1, 3:6)]

names(agre.death) <- c("year",
                       "deaths_a",
                       "deaths_b",
                       "deaths_civilians",
                       "deaths_unknown")

deaths.a.b.c.u.group.melt <- melt(agre.death, id = "year")

# ggplot(deaths.a.b.c.u.group.melt, aes(x = year , y = value)) +
#          geom_bar(stat = "identity")+
#            facet_wrap(~variable)+
#              theme_stata()+
#                theme(axis.text = element_text(size = 9),
#                  axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5),
#                  axis.text.y = element_text(angle = 0, vjust = 0.5, hjust = 0.5))+
#                    ggtitle("Death Category")+
#                       labs(x="Year",
#                            y="Number of Deaths")

```

#### No 1994 again!!

```{r}

ggplot(deaths.a.b.c.u.group.melt[deaths.a.b.c.u.group.melt$year != 1994,],
       aes(
         x = as.factor(year) ,
         y = value,
         fill = as.factor(year)
       )) +
  geom_bar(stat = "identity") +
  facet_wrap( ~ variable) +
  theme_stata() +
  theme(
    axis.text = element_text(size = 9),
    axis.text.x = element_text(
      angle = 90,
      vjust = 0.5,
      hjust = 0.5
    )
  ) +
  theme(legend.position = "none") +
  ggtitle("Death Category") +
  labs(x = "Year (1994 is out)",
       y = "Number of Deaths")

```
Interesting, but more factors need to be Considered.

Now let's move to Event Duration Of One Day

```{r}

##################### One-Day Duration Events
################
##########

ged.1.day <- ged[ged$duration.even == 1, ]

group.1.day <- ged.1.day %>%
  group_by(dyad_name) %>%
  summarise(freq = n())

group.1.day$percent.freq <-
  (round((
    group.1.day$freq / sum(group.1.day$freq) * 100
  ), 2))
 
```

```{r}

ggplot(group.1.day[group.1.day$percent.freq >= 2, ],
       aes(x = reorder(dyad_name, freq) , y = percent.freq)) +
  geom_point(stat = "identity") +
  theme_solarized() +
  theme(
    axis.text = element_text(size = 9),
    axis.text.x = element_text(
      angle = 90,
      vjust = 0.5,
      hjust = 0.5
    )
  ) +
  scale_x_discrete(labels = wrap_format(10)) +
  geom_text(aes(
    label = percent.freq,
    hjust = 0.5,
    vjust = 1.3
  ),
  size = 4,
  color = "darkred") +
  ggtitle("One-Day Duration Events") +
  labs(x = "Side_a",
       y = "Percentage of number of Events")

```

Note: I have replaced the 0 Duration in the duration.even feature with 1.

Government of Afganistan and Taleban , the TOP 1 ..with ~10 % more than the 2nd (Government of India- Kashmir insurgents) 

```{r}
dyad.freq <-
  summarise(group_by(ged, dyad.name = ged$dyad_name), freq = n())

dyad.top.10 <- dyad.freq %>%
  filter(rank(desc(freq)) <= 10)

ggplot(dyad.top.10,
       aes(x = reorder(dyad.name, -freq), y = freq)) +
  geom_bar(stat = "identity", fill = "darkred") +
  ged.theme +
  theme(
    axis.text = element_text(size = 9),
    axis.text.x = element_text(
      angle = 90,
      vjust = 0.5,
      hjust = 0.5
    )
  ) +
  scale_x_discrete(labels = wrap_format(10)) +
  geom_text(aes(
    label = freq,
    hjust = 0.5,
    vjust = 1.3
  ),
  size = 4,
  color = "white") +
  ggtitle("Top 10 Dyad (number of conflicts)") +
  labs(x = "Dyad Name",
       y = "number of conflicts")

```

Thanks