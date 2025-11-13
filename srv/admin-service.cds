using agi.learninghub as learninghub from '../db/schema';

service AdminService @(requires: 'admin') {

  entity Users  as projection on learninghub.Users;
  entity Roles  as projection on learninghub.Roles;

  entity Journeys         as projection on learninghub.Journeys;
  entity Courses          as projection on learninghub.Courses;
  entity Units            as projection on learninghub.Units;
  entity Chapters         as projection on learninghub.Chapters;
  entity Tests            as projection on learninghub.Tests;
  entity Questions        as projection on learninghub.Questions;
  entity Answers          as projection on learninghub.Answers;

  entity Categories       as projection on learninghub.Categories;
  entity Levels           as projection on learninghub.Levels;
  entity JourneyCourses   as projection on learninghub.JourneyCourses;
  entity CourseCategories as projection on learninghub.CourseCategories;

  entity JourneyProgresses  as projection on learninghub.JourneyProgresses;
  entity CourseProgresses   as projection on learninghub.CourseProgresses;
  entity UnitProgresses     as projection on learninghub.UnitProgresses;
  entity ChapterProgresses  as projection on learninghub.ChapterProgresses;
  entity TestProgresses     as projection on learninghub.TestProgresses;
}
