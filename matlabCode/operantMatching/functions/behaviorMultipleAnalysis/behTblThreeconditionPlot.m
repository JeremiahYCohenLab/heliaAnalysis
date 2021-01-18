scatter(behTbl.probability_switchNoRwd_Safe, behTbl.Probability_switchNoRwd_threat, 20, 'filled', 'MarkerFaceColor',[0.3, 0.9, 0]); xlabel('safe  p of switch if No Rwe'); ylabel('threat  p of switch if No Rwe');
hold on; scatter(behTblGood.probability_switchNoRwd_Safe, behTblGood.Probability_switchNoRwd_threat, 30, 'filled', 'MarkerFaceColor',[0.00,0.16,1]);
hold on; scatter(behTblnoManu.probability_switchNoRwd_Safe, behTblnoManu.Probability_switchNoRwd_threat, 45, 'filled', 'MarkerFaceColor',[0.90,0.90,0.00]);
legend('all n31', 'good beh n19', 'no manupulation n15'); hold on;
plot([-1 1],[-1 1],'k:');
%%
%%%
scatter(behTbl.Fraction_rewarded_safe, behTbl.Fraction_rewarded_threat, 20, 'filled', 'MarkerFaceColor',[0.3, 0.9, 0]); xlabel('safe rewarded fraction'); ylabel('threat rewarded fraction');
hold on; scatter(behTblGood.Fraction_rewarded_safe, behTblGood.Fraction_rewarded_threat, 30, 'filled', 'MarkerFaceColor',[0.00,0.16,1]);
hold on; scatter(behTblnoManu.Fraction_rewarded_safe, behTblnoManu.Fraction_rewarded_threat, 45, 'filled', 'MarkerFaceColor',[0.90,0.90,0.00]);
legend('all n31', 'good beh n19', 'no manupulation n15'); hold on;
plot([-1 1],[-1 1],'k:');
%%%
%%
scatter(behTbl.Fraction_rewarded_safe, behTbl.Fraction_rewarded_threat, 20, 'filled', 'MarkerFaceColor',[0.3, 0.9, 0]); xlabel('safe rewarded fraction'); ylabel('threat rewarded fraction');
hold on; scatter(behTblGood.Fraction_rewarded_safe, behTblGood.Fraction_rewarded_threat, 30, 'filled', 'MarkerFaceColor',[0.00,0.16,1]);
hold on; scatter(behTblnoManu.Fraction_rewarded_safe, behTblnoManu.Fraction_rewarded_threat, 45, 'filled', 'MarkerFaceColor',[0.90,0.90,0.00]);
legend('all n31', 'good beh n19', 'no manupulation n15'); hold on;
plot([0 1],[0 1],'k:');
%%
%%%
scatter(behTbl.Probability_stayRwd_safe, behTbl.Probability_stayRwd_threat, 20, 'filled', 'MarkerFaceColor',[0.3, 0.9, 0]); xlabel('safe p of stay/rew'); ylabel('threat p of stay/rew');
hold on; scatter(behTblGood.Probability_stayRwd_safe, behTblGood.Probability_stayRwd_threat, 30, 'filled', 'MarkerFaceColor',[0.00,0.16,1]);
hold on; scatter(behTblnoManu.Probability_stayRwd_safe, behTblnoManu.Probability_stayRwd_threat, 45, 'filled', 'MarkerFaceColor',[0.90,0.90,0.00]);
legend('all n31', 'good beh n19', 'no manupulation n15'); hold on;
plot([-1 1],[-1 1],'k:');
%%%
%%
scatter(behTbl.Norm_switches_safe, behTbl.Norm_switches_threat, 20, 'filled', 'MarkerFaceColor',[0.3, 0.9, 0]); xlabel('safe norm switch'); ylabel('threat norm switch');
hold on; scatter(behTblGood.Norm_switches_safe, behTblGood.Norm_switches_threat, 30, 'filled', 'MarkerFaceColor',[0.00,0.16,1]);
hold on; scatter(behTblnoManu.Norm_switches_safe, behTblnoManu.Norm_switches_threat, 45, 'filled', 'MarkerFaceColor',[0.90,0.90,0.00]);
legend('all n31', 'good beh n19', 'no manupulation n15'); hold on;
plot([-1 1],[-1 1],'k:');
%%
%%%
scatter(behTbl.Fraction_correct_safe, behTbl.Fraction_correct_threat, 20, 'filled', 'MarkerFaceColor',[0.3, 0.9, 0]); xlabel('safe fraction correct'); ylabel('threat fraction correct');
hold on; scatter(behTblGood.Fraction_correct_safe, behTblGood.Fraction_correct_threat, 30, 'filled', 'MarkerFaceColor',[0.00,0.16,1]);
hold on; scatter(behTblnoManu.Fraction_correct_safe, behTblnoManu.Fraction_correct_threat, 45, 'filled', 'MarkerFaceColor',[0.90,0.90,0.00]);
legend('all n31', 'good beh n19', 'no manupulation n15'); hold on;
plot([-1 1],[-1 1],'k:');
