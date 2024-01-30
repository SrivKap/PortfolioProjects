Select * from PortfolioProject.dbo.CovidDeaths$
--where continent is not null
order by 3,4
 
Select distinct continent, location from PortfolioProject.dbo.CovidDeaths$
order by continent
--where continent is not null
--order by 3,4

Select * from PortfolioProject.dbo.CovidVaccinations$
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject.dbo.CovidDeaths$
order by 1,2

--looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (cast(total_deaths as Int)/cast(total_cases as int))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$
order by 1,2

--looking at total cases vs population
--Shows what percentage got Covid

Select location, date, total_cases, total_deaths, (cast(total_cases as FLOAT)/cast(population as FLOAT))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$ where location like '%states%'
order by 1,2

-- lOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION 

Select location,POPULATION, MAX(cast(TOTAL_CASES as float)) AS HIGHESTiNFECTIONcOUNT, MAX(Cast(TOTAl_CASES as float)/cast(POPULATION as float))*100 AS PERCENTPOPULATIONINFECTED
from PortfolioProject.dbo.CovidDeaths$ --where location like '%states%'
Group By location, population
order by percentpopulationinfected desc

--Showing the continents with highest death 
Select continent, MAX(cast(total_deaths as float)) AS HighestDeathCount
from PortfolioProject.dbo.CovidDeaths$ --where location like '%states%'
where continent is not null
Group By continent
order by HighestDeathCount desc
---Showing the countries with the highest death count per population 

Select location, MAX(cast(total_deaths as float)) AS HighestDeathCount
from PortfolioProject.dbo.CovidDeaths$ --where location like '%states%'
where continent is not null
Group By location
order by HighestDeathCount desc

--Global NUmbers by date

Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, (Sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$
where continent is not null 
Group By date
Order By 1, 2

--- Join both tables on date and location 

select * 
from PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date= vac.date

--- looking at total population vas vaccination 

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations , sum(cast(vac.new_vaccinations as float)) over (partition by dea.location) as RollingPeopleVAccinated
from PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null and
vac.new_vaccinations is not null 
Order by 2,3

-- Use CTE temp table for using the derived column 'RollingPeopleVaccinated' for calculations

with PopvsVac (continent, location, date, population, NEw_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, population, vac.new_vaccinations , sum(cast(vac.new_vaccinations as float)) over (partition by dea.location) as RollingPeopleVAccinated
--(RollingPeopleVaccinated/Population) * 100
from PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null 
--vac.new_vaccinations is not null 
--Order by 2,3
)

Select * , (RollingPeopleVaccinated/Population) * 100
from PopvsVac

-- Temp Table

DROP Table if exists #percentPopulateionVaccinated

Create Table #PercentPopulationVaccinated
(
Continent	nVarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccination Numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations , 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location) as RollingPeopleVAccinated
--(RollingPeopleVaccinated/Population) * 100
from PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date= vac.date
--where dea.continent is not null 

Select * , (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated

--Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations , 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location) as RollingPeopleVAccinated
--(RollingPeopleVaccinated/Population) * 100
from PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null 
--order by 2,3

select * from PercentPopulationvaccinated