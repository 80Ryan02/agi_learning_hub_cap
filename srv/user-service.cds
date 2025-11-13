using agi.learninghub as learninghub from '../db/schema';

service UserService @(requires: 'authenticated') {

  entity Journeys         as projection on learninghub.Journeys;
  entity Courses          as projection on learninghub.Courses;
  entity Units            as projection on learninghub.Units;
  entity Chapters         as projection on learninghub.Chapters;
  entity Tests            as projection on learninghub.Tests;

  entity JourneyProgresses  as projection on learninghub.JourneyProgresses;
  entity CourseProgresses   as projection on learninghub.CourseProgresses;
  entity UnitProgresses     as projection on learninghub.UnitProgresses;
  entity ChapterProgresses  as projection on learninghub.ChapterProgresses;
  entity TestProgresses     as projection on learninghub.TestProgresses;
}
