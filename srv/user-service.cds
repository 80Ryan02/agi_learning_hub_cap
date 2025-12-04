using agi.learninghub as lh from '../db/schema';

service UserService @(requires: 'authenticated') {

  @restrict: [{ grant: 'READ', to: 'User' }]
  entity Journeys as projection on lh.Journeys;

  @restrict: [{ grant: 'READ', to: 'User' }]
  entity Courses as projection on lh.Courses;

  @restrict: [{ grant: 'READ', to: 'User' }]
  entity Units as projection on lh.Units;

  @restrict: [{ grant: 'READ', to: 'User' }]
  entity Chapters as projection on lh.Chapters;

  @restrict: [{ grant: 'READ', to: 'User' }]
  entity Tests as projection on lh.Tests;


  @restrict: [
    { grant: 'READ',  to: 'User', where: 'user_ID = $user.id' },
    { grant: 'WRITE', to: 'User', where: 'user_ID = $user.id' }
  ]
  entity MyJourneyProgresses as projection on lh.JourneyProgresses;

  @restrict: [
    { grant: 'READ',  to: 'User', where: 'user_ID = $user.id' },
    { grant: 'WRITE', to: 'User', where: 'user_ID = $user.id' }
  ]
  entity MyCourseProgresses as projection on lh.CourseProgresses;


  @restrict: [
    { grant: ['READ','WRITE'], to: 'User' }
  ]
  entity MyUnitProgresses as projection on lh.UnitProgresses;

  @restrict: [
    { grant: ['READ','WRITE'], to: 'User' }
  ]
  entity MyChapterProgresses as projection on lh.ChapterProgresses;

  @restrict: [
    { grant: ['READ','WRITE'], to: 'User' }
  ]


  entity MyTestProgresses as projection on lh.TestProgresses;

  @restrict: [{ grant: 'EXECUTE', to: 'User' }]
  action submitTest(testProgress_ID : UUID) 
    returns {
      message       : String;
      scorePercent  : Integer;
      passed        : Boolean;
    };
}
