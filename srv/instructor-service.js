const cds = require('@sap/cds');
const { SELECT, INSERT } = cds;

module.exports = (srv) => {

  const {
    JourneyProgresses,
    CourseProgresses,
    UnitProgresses,
    Users,
    Journeys,
    Courses,
    Units
  } = srv.entities;


  async function ensureUserExists(userID, req) {
    const user = await SELECT.one.from(Users).where({ ID: userID });
    if (!user) req.reject(404, req._t('USER_NOT_FOUND'));
    return user;
  }

  async function ensureJourneyExists(journeyID, req) {
    const journey = await SELECT.one.from(Journeys).where({ ID: journeyID });
    if (!journey) req.reject(404, req._t('JOURNEY_NOT_FOUND'));
    return journey;
  }

  async function ensureCourseExists(courseID, req) {
    const course = await SELECT.one.from(Courses).where({ ID: courseID });
    if (!course) req.reject(404, req._t('COURSE_NOT_FOUND'));
    return course;
  }

  async function ensureUnitExists(unitID, req) {
    const unit = await SELECT.one.from(Units).where({ ID: unitID });
    if (!unit) req.reject(404, req._t('UNIT_NOT_FOUND'));
    return unit;
  }


  srv.on('assignJourneyToUser', async (req) => {
    const { journeyID, userID } = req.data;

    await ensureJourneyExists(journeyID, req);
    await ensureUserExists(userID, req);

    const alreadyExists = await SELECT.one.from(JourneyProgresses).where({
      journey_ID: journeyID,
      user_ID: userID
    });

    if (alreadyExists) {
      return req.reject(409, req._t('JOURNEY_ALREADY_ASSIGNED'));
    }

    const result = await INSERT.into(JourneyProgresses).entries({
      journey_ID: journeyID,
      user_ID: userID,
      assigned: true
    });

    return {
      message: req._t('JOURNEY_ASSIGNED'),
      journeyProgressID: result.ID
    };
  });


  srv.on('assignCourseToUser', async (req) => {
    const { courseID, userID } = req.data;

    await ensureCourseExists(courseID, req);
    await ensureUserExists(userID, req);

    const exists = await SELECT.one.from(CourseProgresses).where({
      course_ID: courseID,
      user_ID: userID
    });

    if (exists) {
      return req.reject(409, req._t('COURSE_ALREADY_ASSIGNED'));
    }

    const result = await INSERT.into(CourseProgresses).entries({
      course_ID: courseID,
      user_ID: userID,
      assigned: true
    });

    return {
      message: req._t('COURSE_ASSIGNED'),
      courseProgressID: result.ID
    };
  });


  srv.on('assignUnitToUser', async (req) => {
    const { unitID, userID } = req.data;

    await ensureUnitExists(unitID, req);
    await ensureUserExists(userID, req);

    const exists = await SELECT.one.from(UnitProgresses).where({
      unit_ID: unitID,
      user_ID: userID
    });

    if (exists) {
      return req.reject(409, req._t('UNIT_ALREADY_ASSIGNED'));
    }

    const result = await INSERT.into(UnitProgresses).entries({
      unit_ID: unitID,
      user_ID: userID,
      assigned: true
    });

    return {
      message: req._t('UNIT_ASSIGNED'),
      unitProgressID: result.ID
    };
  });
};
