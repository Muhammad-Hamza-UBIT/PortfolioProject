Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3, 4

--Select Data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where  location like '%states%'
and continent is not null
order by 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where  location like '%states%'
order by 1, 2

Select location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where  location like '%states%'
order by 1, 2

--Looking at Countries with Highest Infection Rate compared  to Population
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where  location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest DeathCount per Population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where  location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--Let's break things down by continent
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where  location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Let's break things down by continent
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where  location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

-- Showing continents with highest deathcounts per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where  location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select date, sum(new_cases)--, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where  location like '%states%'
where continent is not null
group by date
order by 1, 2

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int)) / sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where  location like '%states%'
where continent is not null
group by date
order by 1, 2

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int)) / sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where  location like '%states%'
where continent is not null
order by 1, 2

-- Looking at Total Population vs Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- use CTE
with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population) * 100
from PopvsVac


-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccinated


-- Creating View to Store Data for later Visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
from PercentPopulationVaccinated