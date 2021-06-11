Select *
From Covid19..CovidDeaths
where continent is not null 

--Select *
--From Covid19..CovidVaccinations
--order by 3,4

-- Selecting the data to be used 

Select location, date, total_cases, new_cases, total_deaths, population
From Covid19..CovidDeaths
where continent is not null 
order by 1,2

-- Analysing total cases vs total deaths
-- Shows the likelihood of dying if in contact with the virus

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From Covid19..CovidDeaths
where location like '%india%' and continent is not null 
order by 1,2

--Analysing total cases vs population
--Shows the percentage of people covid positive in the entire population 

Select location, date, total_cases, population, (total_cases/population)*100 as positivity_percentage
From Covid19..CovidDeaths
where location like '%india%'
order by 1,2

--Finding countries with higher infection rates

Select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as positivity_percentage
From Covid19..CovidDeaths
--where location like '%india%'
where continent is not null 
Group by location, population
order by positivity_percentage desc


-- Finding countries with higher death rates

Select location, population, max(cast(total_deaths as int)) as highest_death_count, max((total_deaths/population))*100 as death_percentage
From Covid19..CovidDeaths
--where location like '%india%'
where continent is not null 
Group by location, population
order by death_percentage desc

-- Analysing by breaking things down by continent

Select location, max(cast(total_deaths as int)) as highest_death_count, max((total_deaths/population))*100 as death_percentage
From Covid19..CovidDeaths
--where location like '%india%'
where continent is  null 
Group by location
order by highest_death_count desc


-- Global Covid-19 Analysis
-- Shows death rate each day globally

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 
as death_percentage
From Covid19..CovidDeaths
--where location like '%india%'
where continent is not null 
group by date
order by 1,2


-- Joining the two tables (Death and Vaccination)
-- Looking at total population vs vaccination
-- Showing rolling count of vaccinations by countries

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by 
dea.location order by dea.location,dea.date) as total_vaccinated
from Covid19..CovidDeaths dea
join Covid19..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE for above 

With popvsvac (continent, location, date, population, new_vaccinations, total_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by 
dea.location order by dea.location,dea.date) as total_vaccinated
from Covid19..CovidDeaths dea
join Covid19..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *,(total_vaccinated/population)*100 as pop_vac_pct
from popvsvac


-- Using temperory table 

drop table if exists #pop_vac_pct
create table #pop_vac_pct
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinated numeric
)

insert into #pop_vac_pct
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by 
dea.location order by dea.location,dea.date) as total_vaccinated
from Covid19..CovidDeaths dea
join Covid19..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(total_vaccinated/population)*100 as pct_pop_vac
from #pop_vac_pct


-- Creating view for a later use to create visuals

create view pop_vac_pct as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by 
dea.location order by dea.location,dea.date) as total_vaccinated
from Covid19..CovidDeaths dea
join Covid19..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from pop_vac_pct
