select *
from PortProject..CovidDeaths$
where continent is not null
order by  3,4

--select *
--from PortProject..CovidVaccinations$
--order by  3,4

select location, date, total_cases, new_cases, total_deaths, round(((total_deaths/total_cases)*100),2) as DeathPercentage
from PortProject..CovidDeaths$
where location = 'Canada'
order by 1,2


-- Total cases vs population
select location, date, total_cases, population, round(((total_cases/population)*100),2) as CasePositivePercentage
from PortProject..CovidDeaths$
--where location = 'Canada'
order by 1,2

-- highest infection rate compare to population
select location,population,  max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentagePopulationInfected
from PortProject..CovidDeaths$
group by location,population
order by PercentagePopulationInfected desc

--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeath, max(total_deaths/population)*100 as PercentageDeath
from PortProject..CovidDeaths$
--where location = 'Canada'
where continent is not null
group by location
order by TotalDeath desc 

--Break thing down by continent

-- Showing the continent with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeath
from PortProject..CovidDeaths$
--where location = 'Canada'
where continent is not null
group by continent
order by TotalDeath desc 


--Global nunber
select  sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortProject..CovidDeaths$
where continent is not null
order by 1,2


-- Looking at total population vs vaccination
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
from PortProject..CovidDeaths$  dea
Join PortProject..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
from PortProject..CovidDeaths$  dea
Join PortProject..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
--order by 1,2)
select *, (RollingPeopleVaccinated/Population) *100
from PopvsVac;

--temp table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
new_vaccination int,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
from PortProject..CovidDeaths$  dea
Join PortProject..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * ,(RollingPeopleVaccinated/Population) *100
from #PercentPopulationVaccinated



-- Create view to store data for later visualization
Create View PercentPopulationVaccinated 
as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
from PortProject..CovidDeaths$  dea
Join PortProject..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated