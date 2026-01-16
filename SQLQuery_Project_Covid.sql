USE PortfolioProject;
GO


SELECT *
From PortfolioProject..CovidDeaths
where continent is Not null
order by 3,4



--SELECT *
--From PortfolioProject..CovidVaccin
--order by 3,4



--Select data that we are going to be using 
Select location ,  date , total_cases , new_cases , total_deaths , population 
From PortfolioProject..CovidDeaths
order by 1,2



--Looking at Total cases vs Total deaths
Select location ,  date , total_cases , total_deaths , (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2



--Looking at total cases vs Population 
-- Show what percentage of population got covid  
Select location ,  date , total_cases , population , (total_cases/population)*100 as  PercentagePopulationInfection
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2



--Looking at Countries with highest infection rate compared to population 
Select location , population ,Max(total_cases) as HighestInfectionCount , Max((total_cases/population)*100) as  PercentagePopulationInfection
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location,population
order by PercentagePopulationInfection Desc



--Showing countries with highest Death 
Select location ,Max(cast(total_deaths as int )) as HighestDeathsCount 
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is Not null
Group by location
order by HighestDeathsCount Desc


--Showing continent with highest Death 
Select location ,Max(cast(total_deaths as int )) as HighestDeathsCount 
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is  null
Group by location
order by HighestDeathsCount Desc



--Global Number
Select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int )) as total_deaths , SUM(total_cases/total_deaths)*100 as DeathPercentages
From PortfolioProject..CovidDeaths
  where continent is not null 



  --Looking at Total Population  vs  Vaccination
  Select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location , dea.Date) as RollingPeopleVaccinated
  From PortfolioProject..CovidDeaths dea
  Join PortfolioProject..CovidVaccin vac 
  On dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is Not null
  order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccin vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccin vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccin vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



