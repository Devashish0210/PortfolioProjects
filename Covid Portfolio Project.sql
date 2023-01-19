Select *
From CovidExcel.dbo.CovidDeaths

--Select *
--From CovidExcel.dbo.CovidVaccinations

Select Location,date,total_cases,new_cases,total_deaths,population
From CovidExcel.dbo.CovidDeaths
order by 1,2


--Total Cases vs Total Deaths
Select Location,date,total_cases,total_deaths,((total_deaths/total_cases)*100) as DeathPercentage
From CovidExcel.dbo.CovidDeaths
where location like '%india'
order by 1,2


--Total Cases vs Population
Select Location,date,total_cases,population,((total_cases/population)*100) as PercentPopulationInfected
From CovidExcel.dbo.CovidDeaths
where location like '%india'
order by 1,2


--Countries with highest infection rates vs population
Select Location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as PercentPopulationInfected
From CovidExcel.dbo.CovidDeaths
--where location like '%india'
Group by location, population
order by PercentPopulationInfected desc

--Highest death count per population
Select Location, MAX(cast(total_deaths as int)) as DeathCount
From CovidExcel.dbo.CovidDeaths
--where location like '%india'
where continent is not null
Group by location
order by DeathCount desc


--Categorizing by Continents 
Select location, MAX(cast(total_deaths as int)) as DeathCount
From CovidExcel.dbo.CovidDeaths
--where location like '%india'
where continent is null
Group by location
order by DeathCount desc


--Global Numbers 
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentageGlobal
From CovidExcel.dbo.CovidDeaths
--where location like '%india'
where continent is not null
Group by date
order by 1,2

--Total Population vs Vaccinations
Select *
From CovidExcel..CovidDeaths dea
Join CovidExcel..CovidVaccinations vac
On dea.location = vac.location
and dea.date =  vac.date

--using CTE
with PopvsVac(continent, location, date, population, new_vaccinations, total_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_Vaccinations
From CovidExcel..CovidDeaths dea
Join CovidExcel..CovidVaccinations vac
On dea.location = vac.location
and dea.date =  vac.date
where dea.continent is not null
--order by 2,3
)

Select *, total_vaccinations/Population*100
From PopvsVac

--using TEMP TABLE


--Create Table #PercentPopulationVaccinated
--(
--continent nvarchar(255),
--location nvarchar(255),
--date datetime,
--population numeric,
--new_vaccinations numeric,
--total_vaccinations numeric
--)

-- Insert into #PercentPopulationVaccinated
-- Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_Vaccinations
--From CovidExcel..CovidDeaths dea
--Join CovidExcel..CovidVaccinations vac
--On dea.location = vac.location
--and dea.date =  vac.date
----where dea.continent is not null
----order by 2,3

--Select *, (total_vaccinations/Population)*100
--From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_Vaccinations
From CovidExcel..CovidDeaths dea
Join CovidExcel..CovidVaccinations vac
On dea.location = vac.location
and dea.date =  vac.date
where dea.continent is not null
--order by 2,3
