select *
from PortfolioProject..covidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..covidVaccinations
--order by 3,4


-- Selecting the Data that is going to be used
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs toal deaths
-- Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..covidDeaths
where continent is not null
-- where location like '%India%'
order by 1,2

-- Looking at toatal cases vs population
-- Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
where continent is not null
-- where location like '%India%'
order by 1,2


-- Looking at countries with Highet infections rates
select location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
where continent is not null
-- where location like '%India%'
group by location, population
order by PercentPopulationInfected desc


-- Showing counries with Highest death count per population
select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
-- where location like '%India%'
where continent is not null
group by location
order by TotalDeathCount desc


-- Let's Break Things Down By Continent


-- Showing continents with Highest death count per population
select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
-- where location like '%India%'
where continent is null
group by location
order by TotalDeathCount desc


-- Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) as
DeathPercentage
--, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..covidDeaths
where continent is not null
-- where location like '%India%'
 group by date
order by 1,2

-- total cases and total deaths

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) as
DeathPercentage
--, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..covidDeaths
where continent is not null
-- where location like '%India%'
 -- group by date
order by 1,2






select *
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date


-- Looking at Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3




-- USE CTE

with PopvsVac(Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

)

select *, (RollingPeopleVaccinated/population)*100 from PopVsVac


-- Temp Table
drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
-- where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated




-- creating view to store data for later visualisation

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3


select * 
from PercentPopulationVaccinated
