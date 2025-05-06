select *
from PortfolioProject..CovidDeaths
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
order by 1,2

--total cases vs total death

select location, date, total_cases, total_deaths, population, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%kingdom%'
order by 1,2

--total cases vs population 

select location, date, total_cases, total_deaths, population, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%kingdom%'
order by 1,2

--Highest infection rate

select location, MAX(total_cases) HighestInfectionRate, population, MAX(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
group by location, population
order by PercentagePopulationInfected desc

--Highest Death Rate

select location, Max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

select location, MAX(Cast (total_deaths as float)) HighestInfectionRate, population, MAX(cast (total_deaths as float)/population)*100 as PercentagePopulationDeaths
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
group by location, population
order by PercentagePopulationDeaths desc

--Deaths by Continent

select location, Max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--Global numbers

select date, Sum(new_cases) SumOfNewCases, sum(cast(new_deaths as int)) SumOfNewDeaths, (sum(cast(new_deaths as int))/Sum(new_cases))*100 DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by date
order by 1,2

select Sum(new_cases) SumOfNewCases, sum(cast(new_deaths as int)) SumOfNewDeaths, (sum(cast(new_deaths as int))/Sum(new_cases))*100 DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
--group by date
order by 1,2


--Vaccination table

Select dea.continent, dea.location, dea.date, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	Select *, (RollingPeopleVaccinated/population)*100
	from PopvsVac

--With Temp Table

Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	date datetime,
	Population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

	Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

	Select *, (RollingPeopleVaccinated/population)*100
	from #PercentPopulationVaccinated