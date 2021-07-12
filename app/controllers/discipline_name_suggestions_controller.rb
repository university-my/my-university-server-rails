class DisciplineNameSuggestionsController < ApplicationController
    before_action do
        @university = University.find_by!(url: params[:university_url])
        @discipline = @university.disciplines.friendly.find(params[:id])
    end

    def new
        discipline_name = DisciplineNameSuggestion.new
        respond_to do |format|
            format.html { render :new, locals: { discipline_name: discipline_name } }
        end
    end

    def create
        @suggestion = DisciplineNameSuggestion.new(discipline_name_suggestion_params)
        @suggestion.discipline = @discipline
        @suggestion.save

        if @suggestion.save
            redirect_to :action => 'thanks'
        else
            render :action => 'new'
        end
    end

    def thanks
    end

    private
    def discipline_name_suggestion_params
        params.require(:discipline_name_suggestion).permit(:name)
    end
end
