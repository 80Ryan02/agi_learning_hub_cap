using agi.learninghub from '../db/schema';

service InstructorService @(requires: 'instructor') {

  entity Journeys          as projection on learninghub.Journey;
  entity Courses           as projection on learninghub.Course;
  entity Units             as projection on learninghub.Unit;
  entity Chapters          as projection on learninghub.Chapter;
  entity Tests             as projection on learninghub.Test;
  entity Questions         as projection on learninghub.Question;
  entity Answers           as projection on learninghub.Answer;

  entity JourneyProgresses as projection on learninghub.JourneyProgress;
  entity CourseProgresses  as projection on learninghub.CourseProgress;
  entity UnitProgresses    as projection on learninghub.UnitProgress;
  entity ChapterProgresses as projection on learninghub.ChapterProgress;
  entity TestProgresses    as projection on learninghub.TestProgress;
}
