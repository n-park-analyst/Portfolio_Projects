/*

Queries used for Tableau Project

*/

-- 1.

SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
(SUM(convert(float,new_deaths))/SUM(nullif(convert(float,new_cases),0)))*100 as death_rate
FROM PortfolioProject..compact_coviddeath
--Where location like '%states'
Where continent is not null
--Group By date
Order By 1,2

-- Just a double check based off the data provided
-- Numbers are extremely close so we will keep them - the second includes "international" location

--SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
--(SUM(convert(float,new_deaths))/SUM(nullif(convert(float,new_cases),0)))*100 as death_rate
--FROM PortfolioProject..compact_coviddeath
----Where location like '%states'
--Where location = 'World'
----Group By date
--Order By 1,2

-- 2.
-- We take these out as they are not included in the queries above and want to stay consistent
-- European Union is part of Europe

SELECT location, sum(new_deaths) as total_deaths
FROM PortfolioProject..compact_coviddeath
--Where location like '%states'
Where continent is null
and location not in ('International')
and location not like '%excl.%'
and location not like '%countries%'
and location not like '%World%'
and location not like '%Union%'
and total_deaths is not null
Group By location
Order By total_deaths desc

-- 3.

SELECT location, population, max(total_cases) as Highest_Inf_Count,
Max(CONVERT(float,total_cases) / NULLIF(CONVERT(float,population),0))*100 as population_infected_rate
FROM PortfolioProject..compact_coviddeath
--Where location like '%states'
Group By location, population
Order By 4 desc

-- 4.

SELECT location, population, date, max(total_cases) as Highest_Inf_Count,
Max(CONVERT(float,total_cases) / NULLIF(CONVERT(float,population),0))*100 as population_infected_rate
FROM PortfolioProject..compact_coviddeath
--Where location like '%states'
Group By location, population, date
Order By 4 desc





SELECT *
FROM PortfolioProject..compact_coviddeath
Where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..compact_covidvac
--order by 3,4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..compact_coviddeath
Where continent is not null
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, 
(CONVERT(float,total_deaths) / NULLIF(CONVERT(float,total_cases),0))*100 as death_rate
FROM PortfolioProject..compact_coviddeath
Where location like '%states'
Order By 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid in your country

SELECT location, date, population, total_cases,
(CONVERT(float,total_cases) / NULLIF(CONVERT(float,population),0))*100 as population_infected_rate
FROM PortfolioProject..compact_coviddeath
--Where location like '%states'
Order By 1,2

-- Looking at Countries with highest infection rate compared to population

SELECT location, population, max(total_cases) as Highest_Inf_Count,
Max(CONVERT(float,total_cases) / NULLIF(CONVERT(float,population),0))*100 as population_infected_rate
FROM PortfolioProject..compact_coviddeath
--Where location like '%states'
Group By location, population
Order By 4 desc

-- Showing Countries with highest death count per population

SELECT location, max(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..compact_coviddeath
--Where location like '%states'
Where continent is not null
Group By location
Order By 2 desc

-- Let's break things down by continent
-- Showing continents with highest death count per population

SELECT continent, max(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..compact_coviddeath
--Where location like '%states'
Where continent is not null
Group By continent
Order By 2 desc

-- Global Numbers

SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
(SUM(convert(float,new_deaths))/SUM(nullif(convert(float,new_cases),0)))*100 as death_rate
FROM PortfolioProject..compact_coviddeath
--Where location like '%states'
Where continent is not null
--Group By date
Order By 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
	--(Rolling_People_Vaccinated/population)*100 as population_vaccinated_rate
From PortfolioProject..compact_coviddeath dea
Join PortfolioProject..compact_covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- Use CTE

With PopVsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
	--(Rolling_People_Vaccinated/population)*100 as population_vaccinated_rate
From PortfolioProject..compact_coviddeath dea
Join PortfolioProject..compact_covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (Rolling_People_Vaccinated/population)*100 as population_vaccinated_rate
From PopVsVac

-- Use Temp Table

DROP Table if exists #population_vaccinated_rate
Create Table #population_vaccinated_rate
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations float,
Rolling_People_Vaccinated float
)

Insert into #population_vaccinated_rate
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
	--(Rolling_People_Vaccinated/population)*100 as population_vaccinated_rate
From PortfolioProject..compact_coviddeath dea
Join PortfolioProject..compact_covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *, (Rolling_People_Vaccinated/population)*100 as population_vaccinated_rate
From #population_vaccinated_rate

-- Creating View to store data for future visualizations

Create View population_vaccinated_rate as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
	--(Rolling_People_Vaccinated/population)*100 as population_vaccinated_rate
From PortfolioProject..compact_coviddeath dea
Join PortfolioProject..compact_covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *
From population_vaccinated_rate