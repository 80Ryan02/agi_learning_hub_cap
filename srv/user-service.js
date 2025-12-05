const cds = require('@sap/cds');
const { SELECT, INSERT, UPDATE } = cds;

module.exports = (srv) => {

  const {
    JourneyProgresses,
    CourseProgresses,
    UnitProgresses,
    ChapterProgresses,
    TestProgresses,
    QuestionProgresses,
    AnswerProgresses,
    JourneyCourses,
    Units,
    Chapters,
    Tests,
    Questions,
    Answers
  } = cds.entities('agi.learninghub');

  const deny = (req, msg = 'ERROR.NOT_AUTHORIZED') =>
    req.reject(403, req._t(msg));

  const getRequestId = (req) =>
    req?.data?.ID || req?.params?.[0]?.ID || null;

  async function checkOwnership(req, entity) {
    const targetId = getRequestId(req);
    if (!targetId) return deny(req);

    const targetRecord = await SELECT.one.from(entity).where({ ID: targetId });
    if (!targetRecord) return deny(req, 'ERROR.NOT_FOUND');

    let ownerId = targetRecord.user_ID;

    if (!ownerId && targetRecord.courseProgress_ID) {
      const courseProgress = await SELECT.one
        .from(CourseProgresses)
        .columns('user_ID')
        .where({ ID: targetRecord.courseProgress_ID });

      if (!courseProgress) return deny(req);
      ownerId = courseProgress.user_ID;
    }

    if (ownerId !== req.user.id) return deny(req);
    return targetRecord;
  }

  async function buildJourneyProgress(_, journeyProgressId, journeyId, userId) {
    const journeyCourses = await SELECT.from(JourneyCourses).where({ journey_ID: journeyId });

    for (const journeyCourse of journeyCourses) {
      const courseProgress = await INSERT.into(CourseProgresses).entries({
        course_ID: journeyCourse.course_ID,
        journeyProgress_ID: journeyProgressId,
        user_ID: userId
      });

      await buildCourseProgress(_, courseProgress.ID, journeyCourse.course_ID, userId);
    }
  }


  async function buildCourseProgress(_, courseProgressId, courseId, userId) {
    const courseUnits = await SELECT.from(Units).where({ course_ID: courseId });

    for (const unit of courseUnits) {
      const unitProgress = await INSERT.into(UnitProgresses).entries({
        unit_ID: unit.ID,
        courseProgress_ID: courseProgressId
      });

      await buildChapterProgress(_, unitProgress.ID, unit.ID);
      await buildTestProgress(_, unitProgress.ID, courseProgressId, unit.ID);
    }
  }


  async function buildChapterProgress(_, unitProgressId, unitId) {
    const unitChapters = await SELECT.from(Chapters).where({ unit_ID: unitId });

    for (const chapter of unitChapters) {
      await INSERT.into(ChapterProgresses).entries({
        unitProgress_ID: unitProgressId,
        chapter_ID: chapter.ID,
        isCompleted: false
      });
    }
  }


  async function buildTestProgress(_, unitProgressId, courseProgressId, unitId) {
    const unitTests = await SELECT.from(Tests).where({ unit_ID: unitId });

    for (const test of unitTests) {
      const testProgress = await INSERT.into(TestProgresses).entries({
        unitProgress_ID: unitProgressId,
        courseProgress_ID: courseProgressId,
        test_ID: test.ID,
        title: test.title,
        description: test.description,
        thresholdPercent: test.thresholdPercent,
        timeLimitMinutes: test.timeLimitMinutes
      });

      await copyQuestionsAndAnswers(_, testProgress.ID, test.ID);
    }
  }


  async function copyQuestionsAndAnswers(_, testProgressId, testId) {
    const testQuestions = await SELECT.from(Questions).where({ test_ID: testId });

    for (const question of testQuestions) {
      const questionProgress = await INSERT.into(QuestionProgresses).entries({
        testProgress_ID: testProgressId,
        title: question.title
      });

      const questionAnswers = await SELECT.from(Answers).where({ question_ID: question.ID });

      if (questionAnswers.length > 0) {
        const answerProgressEntries = questionAnswers.map(answer => ({
          questionProgress_ID: questionProgress.ID,
          title: answer.title,
          isCorrect: answer.isCorrect,
          isSelected: false
        }));

        await INSERT.into(AnswerProgresses).entries(answerProgressEntries);
      }
    }
  }

  srv.after('CREATE', JourneyProgresses, async (data, req) => {
    await buildJourneyProgress(null, data.ID, data.journey_ID, req.user.id);
  });

  srv.before('UPDATE', ChapterProgresses, async (req) => {

    if (!req.data.isCompleted) return;

    const chapterProgress = await checkOwnership(req, ChapterProgresses);

    const chapter = await SELECT.one.from(Chapters).where({ ID: chapterProgress.chapter_ID });
    if (!chapter) return req.reject(404, req._t('CHAPTER.NOT_FOUND'));

    const previousChapters = await SELECT.from(Chapters)
      .where({ unit_ID: chapter.unit_ID })
      .and({ order: { '<': chapter.order } });

    if (!previousChapters.length) return;

    const incompletePrevious = await SELECT.from(ChapterProgresses).where({
      unitProgress_ID: chapterProgress.unitProgress_ID,
      chapter_ID: { in: previousChapters.map(ch => ch.ID) },
      isCompleted: false
    });

    if (incompletePrevious.length)
      return req.reject(409, req._t('CHAPTER.PREVIOUS_NOT_COMPLETED'));
  });

  srv.on('submitTest', async (req) => {

    const { testProgress_ID } = req.data;
    if (!testProgress_ID) return req.reject(400, req._t('TEST.PROGRESS_REQUIRED'));

    const testProgress = await SELECT.one.from(TestProgresses).where({ ID: testProgress_ID });
    if (!testProgress) return req.reject(404, req._t('TEST.NOT_FOUND'));

    const courseProgress = await SELECT.one.from(CourseProgresses)
      .where({ ID: testProgress.courseProgress_ID });

    if (!courseProgress || courseProgress.user_ID !== req.user.id)
      return deny(req);

    if (testProgress.passed != null)
      return req.reject(409, req._t('TEST.ALREADY_SUBMITTED'));

    const questionProgressList = await SELECT.from(QuestionProgresses)
      .where({ testProgress_ID });

    const questionIds = questionProgressList.map(question => question.ID);

    const answerProgressList = await SELECT.from(AnswerProgresses)
      .where({ questionProgress_ID: { in: questionIds } });

    const answersByQuestion = new Map();
    answerProgressList.forEach(answer => {
      if (!answersByQuestion.has(answer.questionProgress_ID))
        answersByQuestion.set(answer.questionProgress_ID, []);
      answersByQuestion.get(answer.questionProgress_ID).push(answer);
    });

    let correctAnswers = 0;

    for (const question of questionProgressList) {
      const answers = answersByQuestion.get(question.ID) || [];
      const isCorrect =
        answers.length > 0 &&
        answers.every(ans => ans.isCorrect === ans.isSelected);

      if (isCorrect) correctAnswers++;
    }

    const totalQuestions = questionProgressList.length;
    const scorePercent =
      totalQuestions === 0
        ? 0
        : Math.round((correctAnswers / totalQuestions) * 100);

    const passed = scorePercent >= testProgress.thresholdPercent;

    await UPDATE(TestProgresses)
      .set({ scorePercent, passed })
      .where({ ID: testProgress_ID });

    return {
      message: req._t('TEST.SUBMITTED'),
      scorePercent,
      passed
    };
  });
};
