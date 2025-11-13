using { cuid, managed } from '@sap/cds/common';
namespace agi.learninghub;

entity Roles : cuid, managed {
  title : String(120);
}

entity Users : cuid, managed {
  name       : String(120);
  avatarUrl  : String(255);
  @assert.format: '^[\\w.%+-]+@[\\w.-]+\\.[A-Za-z]{2,}$'
  @assert.notNull
  email      : String(255);
  role       : Association to one Roles;
}

entity Journeys : cuid, managed {
  title              : String(120);
  description        : String;
  isPublic           : Boolean;

  journeyProgresses  : Association to many JourneyProgresses on journeyProgresses.journey = $self;
  journeyCourses     : Composition of many JourneyCourses  on journeyCourses.journey = $self;
}

entity JourneyCourses : cuid, managed {
  journey : Association to one Journeys;
  course  : Association to one Courses;
}

entity Courses : cuid, managed {
  title            : String(120);
  description      : String;
  isPublic         : Boolean;
  level            : Association to one Levels;
  courseCategories : Composition of many CourseCategories on courseCategories.course = $self;
  units            : Composition of many Units on units.course = $self;
  courseProgresses : Composition of many CourseProgresses on courseProgresses.course = $self;
  journeyCourses   : Composition of many JourneyCourses on journeyCourses.course = $self;
}

entity Units : cuid, managed {
  title          : String(120);
  description    : String;
  chapters       : Composition of many Chapters on chapters.unit = $self;
  unitProgresses : Composition of many UnitProgresses on unitProgresses.unit = $self;
  course         : Association to one Courses;
}

entity Chapters : cuid, managed {
  title           : String(120);
  description     : String;
  durationMinutes : Integer;
  htmlContent     : LargeString;
  unit            : Association to one Units;
}

entity Tests : cuid, managed {
  title             : String(250);
  description       : String;
  thresholdPercent  : Integer;
  timeLimitMinutes  : Integer;
  questions         : Composition of many Questions on questions.test = $self;
  unit              : Association to one Units;
  course            : Association to one Courses;
}

entity Questions : cuid, managed {
  title     : String(250);
  test      : Association to one Tests;
  answers   : Composition of many Answers on answers.question = $self;
}

entity Answers : cuid, managed {
  title     : String(250);
  question  : Association to one Questions;
  isCorrect : Boolean;
}

entity JourneyProgresses : cuid, managed {
  journey   : Association to one Journeys;
  user      : Association to one Users;
  favorite  : Boolean;
  assigned  : Boolean;
  deadline  : Date;
}

entity CourseProgresses : cuid, managed {
  course          : Association to one Courses;
  journeyProgress : Association to one JourneyProgresses;
  user            : Association to one Users;
  favorite        : Boolean;
  assigned        : Boolean;
  deadline        : Date;
}

entity UnitProgresses : cuid, managed {
  courseProgress : Association to one CourseProgresses;
  unit           : Association to one Units;
}

entity ChapterProgresses : cuid, managed {
  unitProgress : Association to one UnitProgresses;
  chapter      : Association to one Chapters;
  isCompleted  : Boolean;
}

entity TestProgresses : cuid, managed {
  unitProgress       : Association to one UnitProgresses;
  courseProgress     : Association to one CourseProgresses;
  questionProgresses : Composition of many QuestionProgresses on questionProgresses.testProgress = $self;
  title              : String(250);
  description        : String;
  thresholdPercent   : Integer;
  timeLimitMinutes   : Integer;
}

entity QuestionProgresses : cuid, managed {
  testProgress     : Association to one TestProgresses;
  answerProgresses : Composition of many AnswerProgresses on answerProgresses.questionProgress = $self;
  title            : String(250);
}

entity AnswerProgresses : cuid, managed {
  questionProgress : Association to one QuestionProgresses;
  title            : String(250);
  isCorrect        : Boolean;
  isSelected       : Boolean;
}

entity Levels : cuid, managed {
  title : String(120);
}

entity Categories : cuid, managed {
  title            : String(120);
  courseCategories : Composition of many CourseCategories on courseCategories.category = $self;
}

entity CourseCategories : cuid {
  course   : Association to one Courses;
  category : Association to one Categories;
}
