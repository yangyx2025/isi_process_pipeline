function event_point=FunGetEventTransitionPoint(data,edge,th)
    data(data<th)=0;
    data(data>th)=1;
    diff_data = diff(data);
    switch lower(edge)
        case 'up'
            event_point=find(diff_data==1);
        case 'down'
            event_point=find(diff_data==-1);
        case 'up&down'
            event_point=find(abs(diff_data) == 1);
        otherwise
            keyboard
    end
end
