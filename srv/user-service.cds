using agi.learninghub from '../db/schema';

service UserService @(requires: 'authenticated') {

  entity Journeys           as projection on learninghub.Journey;
  entity Courses            as projection on learninghub.Course;
  entity Units              as projection on learninghub.Unit;
  entity Chapters           as projection on learninghub.Chapter;
  entity Tests              as projection on learninghub.Test;

  entity JourneyProgresses  as projection on learninghub.JourneyProgress;
  entity CourseProgresses   as projection on learninghub.CourseProgress;
  entity UnitProgresses     as projection on learninghub.UnitProgress;
  entity ChapterProgresses  as projection on learninghub.ChapterProgress;
  entity TestProgresses     as projection on learninghub.TestProgress;
}
