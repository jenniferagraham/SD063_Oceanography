function answer = say_what(what_they_said)
%SAY_WHAT check for input and convert to 1/0binary
%
%   say_what (what_they_said)
%
%   INPUT:
%   what_they_said: [str] input from user
%
%   OUTPUT:
%   answer: [num] 1 or 0 where 1 is positive and 0 is negative
%   
%   EXAMPLE USE:
%   stored_cleaning_output=say_what(input('Needs cleaning? yes or no\n', 's'));
%
%   Secret options are available to those who venture into the code

    what_they_said = string(what_they_said);
    possible_positive_answers = {'y';'yes';'Y';'Yes';'1';'yea';'yes please';'Okaaaaay';'yup'};
    possible_negative_answers = {'n';'no';'N';'No';'0';'never';'no thank you';'nope';'Youre avin a larf incha?!';'Gimme more'};

    if ismember(what_they_said, possible_positive_answers)
        answer = 1;
    elseif ismember(what_they_said, possible_negative_answers)
        answer = 0;
    else
        disp("That is simply not an option, please choose:\n " + ...
            "'y','yes','1','Y','yes please' OR  \n" + ...
            "'n','no','0','N','no thank you''\n")
        answer = say_what(input('yes or no\n','s'));
    end
end













