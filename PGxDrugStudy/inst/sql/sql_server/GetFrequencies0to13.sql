--  get-frequencies-query-using-age-at-exposure-excluding-topical--refined-definition-of-incident-use.sql GetFrequencies.sql
{DEFAULT @cdmVersion = 4}

WITH filtered_list_of_exposures AS (	
	SELECT DISTINCT DRUG_EXPOSURE.person_id AS exposed_person_id, CONCEPT_ANCESTOR.ancestor_concept_id as substance_id
	FROM DRUG_EXPOSURE, CONCEPT_ANCESTOR, CONCEPT_RELATIONSHIP, PERSON
	WHERE DRUG_EXPOSURE.DRUG_CONCEPT_ID = CONCEPT_ANCESTOR.descendant_concept_id
		AND   CONCEPT_ANCESTOR.ancestor_concept_id IN (19024063,19055982,19059796,19010652,19035344,19056756,19010886,1201620,1549786,1124957,1539403,1103314,923645,739138,1307046,715939,797617,904453,929887,948078,743670,722031,710062,715259,1310149,1322184,1167322,911735,1346823,1597756,757688,721724,742185,955632,725131,735979,950637,738156,785788,740275,740910,1436678,778268,19014878,1354860,766529,1436650,1762711,716968,1353256,1337620,798834,1714165,1367268,1736971,1797155,1714277,800878,1437379,705755,1502855) --ids of all substances from pharmacogenomic guidelines
{@cdmVersion == 4} ? {
		AND   CONCEPT_RELATIONSHIP.relationship_ID = 4  --relationship points to dosage form concept
} : {
		AND   CONCEPT_RELATIONSHIP.relationship_ID = 'RxNorm has dose form'  --relationship points to dosage form concept
}
		AND   DRUG_EXPOSURE.DRUG_CONCEPT_ID = CONCEPT_RELATIONSHIP.concept_id_1 
		AND   CONCEPT_RELATIONSHIP.concept_id_2 NOT IN (19082224,19082228,19082227,19095973,19082225,19095912,19008697,19082109,19130307,19095972,19082286,19126590,19009068,19016586,19082110,19082108,19102295,19095900,19082226,19057400,19112648,19082222,19095975,40227748,19135439,19135438,19135440,19135446,19082107) --concept ids for topical dosage forms
		AND   DRUG_EXPOSURE.DRUG_EXPOSURE_START_DATE >= CAST('20090101' AS DATE)
		AND   DRUG_EXPOSURE.DRUG_EXPOSURE_START_DATE <= CAST('20121231' AS DATE)
		AND   DRUG_EXPOSURE.person_id = PERSON.person_id 
		AND   (YEAR(DRUG_EXPOSURE.DRUG_EXPOSURE_START_DATE) - PERSON.year_of_birth >= 0)
		AND   (YEAR(DRUG_EXPOSURE.DRUG_EXPOSURE_START_DATE) - PERSON.year_of_birth <= 13)
	EXCEPT
	SELECT DISTINCT DRUG_EXPOSURE.person_id AS exposed_person_id, CONCEPT_ANCESTOR.ancestor_concept_id -- lists substance exposures BEFORE the selected time window. Those don't 'count' because we want to know about incident use.
	FROM DRUG_EXPOSURE, CONCEPT_ANCESTOR, CONCEPT_RELATIONSHIP
	WHERE DRUG_EXPOSURE.DRUG_CONCEPT_ID = CONCEPT_ANCESTOR.descendant_concept_id
		AND   CONCEPT_ANCESTOR.ancestor_concept_id IN (19024063,19055982,19059796,19010652,19035344,19056756,19010886,1201620,1549786,1124957,1539403,1103314,923645,739138,1307046,715939,797617,904453,929887,948078,743670,722031,710062,715259,1310149,1322184,1167322,911735,1346823,1597756,757688,721724,742185,955632,725131,735979,950637,738156,785788,740275,740910,1436678,778268,19014878,1354860,766529,1436650,1762711,716968,1353256,1337620,798834,1714165,1367268,1736971,1797155,1714277,800878,1437379,705755,1502855) --ids of all substances from pharmacogenomic guidelines
{@cdmVersion == 4} ? {
		AND   CONCEPT_RELATIONSHIP.relationship_ID = 4  --relationship points to dosage form concept
} : {
		AND   CONCEPT_RELATIONSHIP.relationship_ID = 'RxNorm has dose form'  --relationship points to dosage form concept
}
		AND   DRUG_EXPOSURE.DRUG_CONCEPT_ID = CONCEPT_RELATIONSHIP.concept_id_1 
		AND   CONCEPT_RELATIONSHIP.concept_id_2 NOT IN (19082224,19082228,19082227,19095973,19082225,19095912,19008697,19082109,19130307,19095972,19082286,19126590,19009068,19016586,19082110,19082108,19102295,19095900,19082226,19057400,19112648,19082222,19095975,40227748,19135439,19135438,19135440,19135446,19082107) --concept ids for topical dosage forms
		AND   DRUG_EXPOSURE.DRUG_EXPOSURE_START_DATE < CAST('20090101' AS DATE)
)
SELECT CONCEPT.concept_name, COUNT(DISTINCT(exposed_person_id)) AS distinct_person_count
FROM filtered_list_of_exposures, CONCEPT
WHERE substance_id = CONCEPT.concept_id
GROUP BY CONCEPT.concept_name
ORDER BY distinct_person_count DESC
