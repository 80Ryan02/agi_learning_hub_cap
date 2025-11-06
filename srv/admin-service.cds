using agi.learninghub from '../db/schema';

service AdminService @(requires: 'admin') {

  entity Users            as projection on learninghub.User;
  entity Roles            as projection on learninghub.Role;

  entity Journeys         as projection on learninghub.Journey;
  entity Courses          as projection on learninghub.Course;
  entity Units            as projection on learninghub.Unit;
  entity Chapters         as projection on learninghub.Chapter;
  entity Tests            as projection on learninghub.Test;
  entity Questions        as projection on learninghub.Question;
  entity Answers          as projection on learninghub.Answer;

  entity Categories       as projection on learninghub.Category;
  entity Levels           as projection on learninghub.Level;
  entity JourneyCourses   as projection on learninghub.JourneyCourse;
  entity CourseCategories as projection on learninghub.CourseCategory;
}
