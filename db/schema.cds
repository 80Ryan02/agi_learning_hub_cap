using { cuid, managed } from '@sap/cds/common';

namespace agi.learninghub;

entity Roles : cuid, managed {
  title : String(120);
}

entity Users : cuid, managed {
  name       : String(120);
  avatarUrl  : String(255);
  // @assert.notNull
  @mandatory
  email      : String(255);
  role       : Association to Roles;
}

entity Journeys : cuid, managed {
  @mandatory
  title       : String(120);
  description : String;
  isPublic    : Boolean;

  journeyProgresses : Association to many JourneyProgresses on journeyProgresses.journey = $self;
  journeyCourses    : Composition of many JourneyCourses on journeyCourses.journey = $self;
}

@assert.unique: {
  fk: [journey,course]
}
entity JourneyCourses : cuid, managed {
  @assert.target
  @mandatory
  journey : Association to Journeys;

  @assert.target
  @mandatory
  course  : Association to Courses;
}

entity Courses : cuid, managed {
  title       : String(120);
  description : String;
  isPublic    : Boolean;

  level            : Association to Levels;
  courseCategories : Composition of many CourseCategories on courseCategories.course = $self;
  units            : Composition of many Units on units.course = $self;
  courseProgresses : Association to many CourseProgresses on courseProgresses.course = $self;
  test: Association to Tests;
}

entity Units : cuid, managed {
  title          : String(120);
  description    : String;
  chapters       : Composition of many Chapters on chapters.unit = $self;
  unitProgresses : Association to many UnitProgresses on unitProgresses.unit = $self;
  course         : Association to Courses;
  test: Association to Tests;
}

@assert.unique: {
  order: [unit, order]
}
entity Chapters : cuid, managed {
  title           : String(120);
  description     : String;
  @assert.range: [0,_]
  order           : Integer @assert.notNull; // OrderNo, damit keine Konflikte mit geschützen Bezeichner in DB Systemen
  durationMinutes : Integer;
  htmlContent     : LargeString;
  unit            : Association to Units;
}

entity Tests : cuid, managed {
  title            : String(250);
  description      : String;
  thresholdPercent : Integer;
  timeLimitMinutes : Integer;

  questions : Composition of many Questions on questions.test = $self;
  unit      : Association to Units;
  course    : Association to Courses;
}

entity Questions : cuid, managed {
  title    : String(250);
  test     : Association to Tests @assert.notNull;
  answers  : Composition of many Answers on answers.question = $self;
}

entity Answers : cuid, managed {
  title     : String(250);
  question  : Association to Questions @assert.notNull;
  isCorrect : Boolean;
}

entity JourneyProgresses : cuid, managed {
  journey  : Association to Journeys;
  @readonly
  user     : Association to Users @cds.on.insert : $user;
  // coursesProgresses: Association to many CourseProgresses...
  favorite : Boolean;
  assigned : Boolean;
  deadline : Date;
}

entity CourseProgresses : cuid, managed {
  course          : Association to Courses;
  journeyProgress : Association to JourneyProgresses;
  user            : Association to Users;
  favorite        : Boolean;
  assigned        : Boolean;
  deadline        : Date;
}

entity UnitProgresses : cuid, managed {
  courseProgress : Association to CourseProgresses;
  unit           : Association to Units;
}

entity ChapterProgresses : cuid, managed {
  unitProgress : Association to UnitProgresses;
  chapter      : Association to Chapters;
  isCompleted  : Boolean; // Einheitlich, entweder immer IS/HAS oder gar nicht...
}

entity TestProgresses : cuid, managed {
  unitProgress       : Association to UnitProgresses;
  courseProgress     : Association to CourseProgresses;

  test               : Association to Tests;

  questionProgresses : Composition of many QuestionProgresses 
                        on questionProgresses.testProgress = $self;

  // title              : String(250);
  // description        : String;
  // thresholdPercent   : Integer;
  // timeLimitMinutes   : Integer;

  scorePercent       : Integer;
  passed             : Boolean;
}

entity QuestionProgresses : cuid, managed {
  testProgress     : Association to TestProgresses;

  question: Association to one Questions;

  answerProgresses : Composition of many AnswerProgresses 
                      on answerProgresses.questionProgress = $self;
  // title            : String(250);
}

entity AnswerProgresses : cuid, managed {
  questionProgress : Association to QuestionProgresses;
  // title            : String(250);
  isCorrect        : Boolean;
  isSelected       : Boolean;
}

// CodeList
entity Levels : cuid, managed {
  title : String(120);
}

entity Categories : cuid, managed {
  title            : String(120);
  courseCategories : Composition of many CourseCategories on courseCategories.category = $self;
}

entity CourseCategories : cuid {
  course   : Association to Courses;
  category : Association to Categories;
}
