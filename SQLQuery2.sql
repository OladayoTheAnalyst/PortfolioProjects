Select *
From PortfolioProject..Coviddeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccination$
--order by 3,4

--select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Coviddeaths$
where continent is not null
order by 1,2

--Total cases vs Total Deaths in Percentage
-- Shows the likelihood of dying if you contract covid.
-- This result still shows a relatively low mortality from covid in Nigeria

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..Coviddeaths$
where location like '%nigeria%'
and continent is not null
order by 1,2


--looking at total cases vs the population
-- Show what percentage of the population got covid 


select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..Coviddeaths$
-- where location like '%nigeria%'
where continent is not null
order by 1,2


-- looking at countries with highest infection rates comapared to population


select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..Coviddeaths$
-- where location like '%states%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc
-- Montenegro has the highest infection count with an alarming 24% of the total population infected
-- Sint Maarten comes in last. They have the least infeceted population of Covid


-- Showing Countries with the Highest Death Count per population


select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..Coviddeaths$
-- where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- A better way is show this is below


select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..Coviddeaths$
-- where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc


-- Lets Break things Down by Continent
-- Showing Continents with the highest death count per population


select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..Coviddeaths$
-- where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- Total cases and total deaths globally

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..Coviddeaths$
-- where location like '%states%'
where continent is not null
-- Group by date
order by 1,2


-- Let's merge the two tables together

select *
from PortfolioProject..CovidVaccination$

-- to Join the tables together
-- Looking at total Population vs Vaccinations

select *
from PortfolioProject..Coviddeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..Coviddeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..Coviddeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--use CTE

With Popvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVacinated/population)*100
from PortfolioProject..Coviddeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from Popvac



-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Drop Table if exists #PercentPopulationVaccinatedreal 

Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVacinated/population)*100
from PortfolioProject..Coviddeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated 



-- Creating View To Store Data for Visualizations
-- View for TotalDeathCounts across all continents
Create view TotalDeathCounts as
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..Coviddeaths$
-- where location like '%states%'
where continent is not null
Group by continent
-- order by TotalDeathCount desc


Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVacinated/population)*100
from PortfolioProject..Coviddeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3


select *
from PercentPopulationVaccinated

