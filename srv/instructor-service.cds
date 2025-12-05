using agi.learninghub as lh from '../db/schema';

service InstructorService @(requires: 'Instructor') {

  @restrict: [
    { grant: ['READ', 'CREATE', 'UPDATE'], to: 'Instructor' }
  ]
  entity Journeys as projection on lh.Journeys;

  @restrict: [
    { grant: ['READ', 'CREATE', 'UPDATE'], to: 'Instructor' }
  ]
  entity Courses as projection on lh.Courses;

  @restrict: [
    { grant: ['READ', 'CREATE', 'UPDATE'], to: 'Instructor' }
  ]
  entity Units as projection on lh.Units;

  @restrict: [
    { grant: ['READ', 'CREATE', 'UPDATE'], to: 'Instructor' }
  ]
  entity Chapters as projection on lh.Chapters;

  @restrict: [
    { grant: ['READ', 'CREATE', 'UPDATE'], to: 'Instructor' }
  ]
  entity Tests as projection on lh.Tests;

  @restrict: [
    { grant: ['READ', 'CREATE', 'UPDATE'], to: 'Instructor' }
  ]
  entity Questions as projection on lh.Questions;

  @restrict: [
    { grant: ['READ', 'CREATE', 'UPDATE'], to: 'Instructor' }
  ]
  entity Answers as projection on lh.Answers;


  @restrict: [
    { grant: ['READ'], to: 'Instructor' }
  ]
  entity Users as projection on lh.Users;


  @restrict: [
    { grant: ['READ'], to: 'Instructor' }
  ]
  entity JourneyProgresses as projection on lh.JourneyProgresses;

  @restrict: [
    { grant: ['READ'], to: 'Instructor' }
  ]
  entity CourseProgresses as projection on lh.CourseProgresses;

  @restrict: [
    { grant: ['READ'], to: 'Instructor' }
  ]
  entity UnitProgresses as projection on lh.UnitProgresses;

  @restrict: [
    { grant: ['READ'], to: 'Instructor' }
  ]
  entity ChapterProgresses as projection on lh.ChapterProgresses;

  @restrict: [
    { grant: ['READ'], to: 'Instructor' }
  ]
  entity TestProgresses as projection on lh.TestProgresses;

  @restrict: [
    { grant: 'EXECUTE', to: 'Instructor' }
  ]
  action assignJourneyToUser(
    journeyID : UUID,
    userID    : UUID
  ) returns {
    message           : String;
    journeyProgressID : UUID;
  };

  @restrict: [
    { grant: 'EXECUTE', to: 'Instructor' }
  ]
  action assignCourseToUser(
    courseID : UUID,
    userID   : UUID
  ) returns {
    message          : String;
    courseProgressID : UUID;
  };

  @restrict: [
    { grant: 'EXECUTE', to: 'Instructor' }
  ]
  action assignUnitToUser(
    unitID  : UUID,
    userID  : UUID
  ) returns {
    message         : String;
    unitProgressID  : UUID;
  };

}
