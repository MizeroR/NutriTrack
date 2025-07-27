const foodNutrition = require("../data/foodNutrition.json");

const DAILY_TARGETS = {
  calories: 2500,
  protein: 71,
  iron: 27,
};

function analyzeNutrition(logs, days = 7) {
  const totals = { calories: 0, protein: 0, iron: 0 };

  for (const log of logs) {
    const match = log.body.trim().match(/^([A-Z]+)\s+([0-9.]+)([a-zA-Z]*)$/);
    if (!match) continue;

    const food = match[1].toLowerCase();
    const quantity = parseFloat(match[2]);

    const nutrientInfo = foodNutrition[food];
    if (!nutrientInfo) continue;

    totals.calories += (nutrientInfo.calories || 0) * quantity;
    totals.protein += (nutrientInfo.protein || 0) * quantity;
    totals.iron += (nutrientInfo.iron || 0) * quantity;
  }

  const targets = {
    calories: DAILY_TARGETS.calories * days,
    protein: DAILY_TARGETS.protein * days,
    iron: DAILY_TARGETS.iron * days,
  };

  const percentMet = {
    calories: Math.round((totals.calories / targets.calories) * 100),
    protein: Math.round((totals.protein / targets.protein) * 100),
    iron: Math.round((totals.iron / targets.iron) * 100),
  };

  const flags = [];
  const recommendations = [];

  if (percentMet.iron < 50) {
    flags.push(`Severely low iron intake (${percentMet.iron}%)`);
    recommendations.push(
      "Increase iron-rich foods: beans, leafy greens, meat."
    );
  }

  if (percentMet.protein < 60) {
    flags.push(`Low protein intake (${percentMet.protein}%)`);
    recommendations.push("Add more protein: eggs, milk, legumes.");
  }

  if (percentMet.calories < 80) {
    flags.push(`Low caloric intake (${percentMet.calories}%)`);
    recommendations.push("Try to eat more energy-rich meals.");
  }

  return {
    totals,
    targets,
    percentMet,
    flags,
    recommendations,
  };
}

module.exports = { analyzeNutrition };
