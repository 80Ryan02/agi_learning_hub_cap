using agi.learninghub as lh from '../db/schema';

service InstructorService @(requires: 'Instructor') {

  entity Journeys as projection on lh.Journeys;
  entity Courses as projection on lh.Courses;
  entity Units as projection on lh.Units;
  entity Chapters as projection on lh.Chapters;
  entity Tests as projection on lh.Tests;
}
