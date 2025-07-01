select location, date, total_cases, new_cases, total_deaths, population from CovidDeaths order by 1, 2

-- total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as total_death_percentage from CovidDeaths where location like 'bahrain' and (total_deaths/total_cases)*100 > 0.5 order by 1, 2

--select location, max(cast(total_deaths as int)) as total_death_count 
from CovidDeaths 
where continent is null 
group by location order by total_death_count desc

--continents with highest death per population
select location, max(total_deaths/population) as total_death_count 
from CovidDeaths 
where continent is null 
group by location order by total_death_count asc

--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2



with PopVsVac (continent, location, date, population, new_vaccinations, rolling_sum_of_vaccines)
as (
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.DATE) as rolling_sum_of_vaccines
from CovidDeaths as dea
join
CovidVax as vax
on dea.location = vax.location and dea.date = vax.date
where dea.continent is not null
)
select *, (rolling_sum_of_vaccines/population)*100 as percentage_vaccinated_by_population
from PopVsVac

--create view for visualization

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.DATE) as rolling_sum_of_vaccines
from CovidDeaths as dea
join
CovidVax as vax
on dea.location = vax.location and dea.date = vax.date
where dea.continent is not null