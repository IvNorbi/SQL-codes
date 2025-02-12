
-- KETTÕ TESZTLEKÉRDEZÉS A TÁBLÁKRA: 
--Select *
--FROM PortfolioProject..CovidDeaths
--order by 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Adat(ok) kiválasztása 
Select country, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2


-- Megbetegedések, és halálozások összehasonlítása
SELECT country, 
       date, 
       total_cases, 
       total_deaths, 
       CASE 
           WHEN total_deaths = 0 OR total_cases = 0  THEN 0 
           ELSE (total_deaths / total_cases) *100 
       END AS HalalozasiAranySzazalek
FROM PortfolioProject..CovidDeaths 
--Where country = 'Hungary'
ORDER BY HalalozasiAranySzazalek DESC;


-- Megbetegedések aránya a lakossággal százalékban számítva.
-- Megmutatja, a lakosság hány %-a volt covidos összesen.
SELECT country, 
       date, 
       total_cases,
       population,
       CASE 
           WHEN total_cases = 0 OR population = 0 THEN NULL
           ELSE (total_cases * 1.0 / population) * 100
       END AS eredmenyszazalek
FROM PortfolioProject..CovidDeaths 
ORDER BY eredmenyszazalek DESC;


-- Országok szûrése, a legmagasabb megbetegedési rátával, összehasonlítva a populációval.
SELECT country,
       MAX(total_cases) as LegmagasabbFertozesSzam,
       population,
       Max(total_cases/population) * 100 as eredmeny
FROM PortfolioProject..CovidDeaths 
GROUP BY country, population
ORDER BY eredmeny DESC


--Országok listázása a legmagasabb halálozási aránnyal / lakosság.
SELECT country,
		MAX(cast(total_deaths as int)) as osszesHalalEset
FROM PortfolioProject..CovidDeaths 
WHERE country is not null 
AND country NOT IN ('World', 'Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceania', 'World excl China', 'World excl. China and South Korea','World excl. China, South Korea, Japan and Singapore','High-income countries','Upper-middle-income countries', 'Asia excl. China', 'Lower-middle-income countries', 'World excl. China')
GROUP BY country
ORDER BY osszesHalalEset DESC


-- KONTINENSEKRE LEBONTVA:
SELECT country, 
		MAX(cast(total_deaths as int)) as osszesHalalEset
FROM PortfolioProject..CovidDeaths 
WHERE country IN ('Europe', 'South America', 'North America', 'Africa', 'Oceania')
group by country
ORDER BY osszesHalalEset DESC


--Kontinens, ahol a legmagasabb volt a halálozási arány:
SELECT country, MAX(cast(total_deaths as int)) as osszesHalalEset
FROM PortfolioProject..CovidDeaths 
WHERE country IN ('Europe', 'South America', 'North America', 'Africa', 'Oceania')
group by country
ORDER BY osszesHalalEset DESC


--GLOBÁLIS SZÁMOK (világszerte):
SELECT SUM(new_cases) as FertozottekSzama,
	   SUM(new_deaths) as HalalozasokSzama,
	   SUM(NULLIF(new_deaths, 0)) / SUM(NULLIF(new_cases, 0)) *100  as HalalozasAranySzazalek
FROM PortfolioProject..CovidDeaths 
ORDER BY 1,2 

-- Világ populáció / oltási arány
SELECT  dea.country,
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (Partition by dea.country ORDER BY dea.country, dea.Date) as FolyamatosanNovekvoOltottakSzama
--		(FolyamatosanNovekvoOltottakSzama/population) *100 -> nem lesz jó, CTE megoldás alatta:
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.country = vac.country
	and dea.date = vac.date
ORDER BY 1, 2, 3 

-- CTE:
WITH PopVsVac AS 
(
    SELECT  dea.country,
            dea.date, 
            dea.population, 
            vac.new_vaccinations,
            SUM(CONVERT(FLOAT, vac.new_vaccinations)) 
                OVER (PARTITION BY dea.country ORDER BY dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as FolyamatosanNovekvoOltottakSzama
    FROM PortfolioProject..CovidDeaths dea
    JOIN (
        SELECT country, date, SUM(CONVERT(FLOAT, new_vaccinations)) AS new_vaccinations
        FROM PortfolioProject..CovidVaccinations
        WHERE new_vaccinations IS NOT NULL
        GROUP BY country, date
    ) vac
    ON dea.country = vac.country
    AND dea.date = vac.date
)
SELECT  country,
        date,
        population,
        new_vaccinations,
        FolyamatosanNovekvoOltottakSzama,
        CASE 
            WHEN population > 0 THEN (FolyamatosanNovekvoOltottakSzama / population) * 100 
            ELSE 0 
        END AS PopulacioOltottsagaSzazalek
FROM PopVsVac
WHERE FolyamatosanNovekvoOltottakSzama <= population 
--AND country = 'Hungary'
ORDER BY country, date;





















