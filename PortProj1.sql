
select *
from PortfolioProject..CovidDeaths
--WHERE location NOT IN ('Africa', 'Asia', 'South America', 'Europe','North America', 'Antarctica', 'Australia') and location is not Null
order by 3, 4


-- Total cases and death per location
select location, date, total_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where location is not null
order by 1, 2

--Percenatge of death across all locations
SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS int) / CAST(total_cases AS int)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where location is not null
order by 1, 2

--Percenatge of death in Nigeria alone
SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS int) / CAST(total_cases AS int)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1, 2

--Total cases and deaths per million
Select location, date, total_cases, total_deaths, population, total_cases_per_million, total_deaths_per_million
from PortfolioProject..CovidDeaths
WHERE location NOT IN ('Africa', 'Asia', 'South America', 'Europe','North America', 'Antarctica', 'Australia')
order by 1, 2


--Total number of people with Covid in Nigeria alone
Select location, date, total_cases, population, (CAST(total_cases as int)/population)*100 as PopWithCovid
from PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2

--Total number of people with Covid across the globe
--Select location, date, total_cases, population, (CAST(total_cases as float)/population)*100 as PopWithCovid
--from PortfolioProject..CovidDeaths
--order by 1,2


--HighestInfectionCount and PercentagePopInfected
Select location, population, Max(cast(total_cases as int)) as HighestInfectionCount, Max((CAST(total_cases as int)/population))*100 as PercentagePopInfected
from PortfolioProject..CovidDeaths
WHERE location NOT IN ('Africa', 'Asia', 'South America', 'Europe','North America', 'Antarctica', 'Australia') and location is not Null
Group by location, population
order by PercentagePopInfected desc


--HighestInfectionCount
Select location, population, Max(cast(total_cases as int)) as HighestInfectionCount
from PortfolioProject..CovidDeaths
where continent is not null
--WHERE location NOT IN ('Africa', 'Asia', 'South America', 'Europe','North America', 'Antarctica', 'Australia', 'World', 'High income', 'Upper middle income', 'Lower middle income', 'European Union') and location is not Null
Group by location, population
order by HighestInfectionCount desc


--TotalDeathCount per Countries alone
Select location, Max(cast(total_cases as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where continent is not null
WHERE location NOT IN ('Africa', 'Asia', 'South America', 'Europe','North America', 'Antarctica', 'Australia', 'World', 'High income', 'Upper middle income', 'Lower middle income', 'European Union') and location is not Null
Group by location
order by TotalDeathCount desc

--Select location, Max(cast(total_cases as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths
--where continent is not null
--Group by location
--order by TotalDeathCount desc

--TotalDeathCount per Continent
Select continent, Max(cast(total_cases as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--TotalDeathCount where location is sorted by income class
Select location, Max(cast(total_cases as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where location in ('World', 'High income', 'Upper middle income', 'Lower middle income', 'European Union')
Group by location
order by TotalDeathCount desc

--Total deaths in locations asides Countries
Select location, Max(cast(total_cases as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS
--Total cases per day
Select date, Sum(Cast(new_cases as int)) as TotalNewCases
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by TotalNewCases


Select date, location, Sum(cast(new_cases as int)) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths
from PortfolioProject..CovidDeaths
where continent is not null
Group by date, location
order by TotalNewDeaths 


Select date, Sum(cast(new_cases as int)) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/Nullif(Sum(new_cases), 0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1, 2 

Select location, Sum(cast(new_cases as int)) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/Nullif(Sum(new_cases), 0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by 1, 2 

Select Sum(cast(new_cases as int)) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/Nullif(Sum(new_cases), 0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2 


select *
from PortfolioProject..CovidVaccinations
order by 3,4


--Total population vs vaccinations

select *
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date)
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


---CTE
With PopvsVac (Continent, location, Date, Population, new_vaccinatons, RollingPeopleVac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
select *, (RollingPeopleVac/Population)*100
From PopvsVac



--Temp Table
Drop table if exists #PercentagePopulationVaccinated

Create Table #PercentagePopulationVaccinated
(
Continent nvarchar (255),
location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVac numeric
)

Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

select *, (RollingPeopleVac/Population)*100
From #PercentagePopulationVaccinated


--Creating Views for Visualization purpose
Create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

DROP VIEW if exists PercentagePopulationVaccinated

select *
from PercentagePopulationVaccinated



