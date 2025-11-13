using agi.learninghub as learninghub from '../db/schema';

service InstructorService @(requires: 'instructor') {

  entity Journeys         as projection on learninghub.Journeys;
  entity Courses          as projection on learninghub.Courses;
  entity Units            as projection on learninghub.Units;
  entity Chapters         as projection on learninghub.Chapters;
  entity Tests            as projection on learninghub.Tests;
  entity Questions        as projection on learninghub.Questions;
  entity Answers          as projection on learninghub.Answers;

  entity JourneyProgresses  as projection on learninghub.JourneyProgresses;
  entity CourseProgresses   as projection on learninghub.CourseProgresses;
  entity UnitProgresses     as projection on learninghub.UnitProgresses;
  entity ChapterProgresses  as projection on learninghub.ChapterProgresses;
  entity TestProgresses     as projection on learninghub.TestProgresses;
}
