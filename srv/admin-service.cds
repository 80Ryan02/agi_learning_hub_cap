using agi.learninghub as lh from '../db/schema';

service AdminService @(requires: 'admin') {

  @restrict: [
    { grant: ['READ','CREATE','UPDATE'], to: 'admin' }
  ]
  entity Users as projection on lh.Users;

  @restrict: [
    { grant: ['READ','CREATE','UPDATE'], to: 'admin' }
  ]
  entity Roles as projection on lh.Roles;

  @restrict: [
    { grant: ['READ','CREATE','UPDATE'], to: 'admin' }
  ]
  entity Levels as projection on lh.Levels;

  @restrict: [
    { grant: ['READ','CREATE','UPDATE'], to: 'admin' }
  ]
  entity Categories as projection on lh.Categories;

  @restrict: [
    { grant: ['READ'], to: 'admin' }
  ]
  entity JourneyProgresses as projection on lh.JourneyProgresses;

  @restrict: [
    { grant: ['READ'], to: 'admin' }
  ]
  entity CourseProgresses as projection on lh.CourseProgresses;

  @restrict: [
    { grant: ['READ'], to: 'admin' }
  ]
  entity UnitProgresses as projection on lh.UnitProgresses;

  @restrict: [
    { grant: ['READ'], to: 'admin' }
  ]
  entity ChapterProgresses as projection on lh.ChapterProgresses;

  @restrict: [
    { grant: ['READ'], to: 'admin' }
  ]
  entity TestProgresses as projection on lh.TestProgresses;

}
