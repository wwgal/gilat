%% generate wc mat
wc_data_file='C:\WC data\gilat_all_avg_data_050419';

%time variables from excel
[~,excel_timevolt_label]= xlsread(wc_data_file,'timevolt');
wc_avg_time=datetime(excel_timevolt_label(2:end,1),'InputFormat','dd/MM/yy');

% [~,tdt_depth_labels]=xlsread('C:\WC data\tdt_depth','tdt','B1:B24');

[excel_wc]= xlsread(wc_data_file,'wc');


tmax=1006;
wc_data=zeros(tmax,8,3);

count=0;
for vms=1:8
    for depth=1:3
        count=count+1;
        wc_data(:,vms,depth)=excel_wc(1:tmax,count);
    end
end
save('C:\WC data\wc_data.mat','wc_data')

serial_nums=zeros(8,3);

serial_nums(:,1)=(33:3:54)';
serial_nums(:,2)=(34:3:55)';
serial_nums(:,3)=(35:3:56)';
save('C:\WC data\serial_nums.mat','serial_nums')


[depth_data,~]=xlsread('C:\WC data\tdt_depth','tdt','D1:D24');

depths_mat=zeros(8,3);

depths_mat(:,1)=depth_data(1:3:22);
depths_mat(:,2)=depth_data(2:3:23);
depths_mat(:,3)=depth_data(3:3:24);
save('C:\WC data\depths.mat','depths')

%% read wc mat and remove NaNs
wc_directory='C:\WC data';
% file_date='021018';
% avg_data_file=[wc_directory '\gilat_all_avg_data_' file_date];

wc_tensor_file='\wc_data.mat';



wc=importdata([wc_directory wc_tensor_file]);
% depths=importdata([wc_directory '\depths.mat']);
% serial_nums=importdata([wc_directory '\serial_nums.mat']);

wc_clean_ind=not(sum(sum(isnan(wc),3),2));
wc_clean=wc(wc_clean_ind,:,:);

save([wc_directory '\wc_NANclean.mat'],'wc_clean','-mat')
save([wc_directory '\wc_NANclean_ind.mat'],'wc_clean_ind','-mat')
% a=ones(4,4,4);
% a(1,1,1)=NaN;
% a(3,2,2)=NaN;
% a(3,3,4)=NaN;
% a(:,4,1)=([1 2 3 4])';
% a(:,4,2)=([5 6 7 8])';
% a(:,4,3)=([9 10 11 12])';
% a(:,4,4)=([13 14 15 16])';
% 
% aind=not(sum(sum(isnan(a),3),2));
% b=a(aind,:,:);

%% Nitrate
laptop_dir='C:\Users\wwgal\Documents\MEGA';
desktop_dir='E:\Mega';
current_pc_dir=desktop_dir;
% data_source=1;%NO3
data_source=2;%Cl

% n_dir=[current_pc_dir '\gilat\Gilat_DATA\ions'];
% n_src_file='\Nitrate_data.csv';
% 
% n_data=load([n_dir n_src_file]);

NO3_path=[current_pc_dir '\gilat\Gilat_DATA\ions'];
out_path=[current_pc_dir '\gilat\Gilat_DATA\Boian\data4Boian'];

if data_source==1
    NO3_data_file='\Nitrate results.xlsx';
    [NO3_data,NO3_txt,~]=xlsread([NO3_path NO3_data_file],'N-NO3_raw_data');
elseif data_source==2
    Cl_data_file='\Chloride.xlsx';
    [NO3_data,NO3_txt,~]=xlsread([NO3_path Cl_data_file],'Cl_raw_data');
end

NO3_values=NO3_data(3:end,:);
NO3_time=datetime(NO3_txt(3:end,1),'InputFormat','dd/MM/yy');
NO3_vsp_num=NO3_data(1,:);
NO3_vsp_name=NO3_txt(2,2:end);

depths=4;
selected_sensors=repmat(logical([ones(1,depths) zeros(1,4-depths)]),1,8);
% n_frame=1:35;%!!!!!!!!!!!!!!!!!!!!!!!!!!!
n_frame=1:45;
n_t_frame=NO3_time(n_frame);
%n_in_t_frame=NO3_values(n_frame,:);
n_in_t_frame=NO3_values(n_frame,selected_sensors);


n_filled=fillmissing(n_in_t_frame,'previous');
n_filled=fillmissing(n_filled,'next');

%adjusting into a continuous time series
n_t_frame_cont=(datetime(n_t_frame(1):n_t_frame(end),'Format','dd-MMM-yyyy'))';

n_cont=NaN(length(n_t_frame_cont),length(n_filled(1,:)));
measured_ind=ismember(n_t_frame_cont,n_t_frame);

n_cont(measured_ind,:)=n_filled;
n_cont=fillmissing(n_cont,'linear');

n_data_mat=zeros(length(n_cont(:,1)),8,depths);
n_data_mat_reorg=n_data_mat;

count=0;
conc_vms=[2 4 5 7 1 3 6 8];
for vms=1:8
    for depth=1:depths
        count=count+1;
        n_data_mat(:,vms,depth)=n_cont(:,count);%!!!!!!!!!!!!!!!
        
    end
end

%serial numbers mat:
conc_serial_nums1=zeros(8,4);
conc_serial_nums1(:,1)=(1:4:29)';
conc_serial_nums1(:,2)=(2:4:30)';
conc_serial_nums1(:,3)=(3:4:31)';
conc_serial_nums1(:,4)=(4:4:32)';

%depths mat:
[depth_data,~]=xlsread([current_pc_dir '\gilat\sensors_legend.csv'],'sensors_legend','D2:D33');
conc_depths1=zeros(8,4);
conc_depths1(:,1)=depth_data(1:4:29);
conc_depths1(:,2)=depth_data(2:4:30);
conc_depths1(:,3)=depth_data(3:4:31);
conc_depths1(:,4)=depth_data(4:4:32);

%adjust to correspond with the order of plots in wc data:
conc_serial_nums_reorg=zeros(size(conc_serial_nums1));
conc_depths_reorg=conc_serial_nums_reorg;
for vms=1:8
    for depth=1:depths
        count=count+1;
        n_data_mat_reorg(:,conc_vms(vms),depth)=n_data_mat(:,vms,depth);
    end
    conc_serial_nums_reorg(conc_vms(vms),:)=conc_serial_nums1(vms,:);
    conc_depths_reorg(conc_vms(vms),:)=conc_depths1(vms,:);
end

if data_source==1
    n_data=n_data_mat_reorg;
    save([out_path '\n_data' num2str(depths) '.mat'],'n_data')
elseif data_source==2
    Cl_data=n_data_mat_reorg;
    save([out_path '\Cl_data' num2str(depths) '.mat'],'Cl_data')
end
conc_serial_nums=conc_serial_nums_reorg;
save([out_path '\conc_serial_nums.mat'],'conc_serial_nums')

conc_depths=conc_depths_reorg;
save([out_path '\conc_depths.mat'],'conc_depths')

%% Bromide
laptop_dir='C:\Users\wwgal\Documents\MEGA';
desktop_dir='E:\Mega';
current_pc_dir=desktop_dir;


br_data_file='\all_bromide_Aug2018.xlsx';
br_path=[current_pc_dir '\gilat\Gilat_DATA\Bromide'];
out_path=[current_pc_dir '\gilat\Gilat_DATA\data4Boian'];

[br_src_data,br_txt,~]=xlsread([br_path br_data_file],'br_raw_data');
br_values=br_src_data(3:end,:);
br_time=datetime(br_txt(3:end,1),'InputFormat','dd/MM/yy');
br_vsp_num=br_src_data(1,:);
br_vsp_name=br_txt(2,2:end);

depths=3;
selected_sensors=repmat(logical([ones(1,depths) zeros(1,4-depths)]),1,8);
br_frame=4:43;%there is a difference in original time frame between n and br source data
% br_frame=4:53;
br_t_frame=br_time(br_frame);
% br_in_t_frame=br_values(br_frame,:);
br_in_t_frame=br_values(br_frame,selected_sensors);


br_filled2=fillmissing(br_in_t_frame,'previous');
br_filled1=br_filled2;
% meas_vsp_ind=[1:7 9:20 22:27 30:32];
meas_vsp_ind=logical([ones(1,7) 0 ones(1,12) 0 ones(1,6) 0 0 ones(1,3)]);
br_filled2(:,meas_vsp_ind(selected_sensors))=fillmissing(br_filled2(:,meas_vsp_ind(selected_sensors)),'constant',0);%!!!!!!!!!!!!!!!!!
% br_filled2(:,and(meas_vsp_ind,selected_sensors))=fillmissing(br_filled2(:,and(meas_vsp_ind,selected_sensors)),'constant',0);%!!!!!!!!!!!!!!!!!
% br_filled2=fillmissing(br_filled2,'constant',0);

%adjusting into a continuous time series
br_t_frame_cont=(datetime(br_t_frame(1):br_t_frame(end),'Format','dd-MMM-yyyy'))';

br_cont=NaN(length(br_t_frame_cont),length(br_filled2(1,:)));
measured_ind=ismember(br_t_frame_cont,br_t_frame);

br_cont(measured_ind,:)=br_filled2;
br_cont=fillmissing(br_cont,'linear');


%create bromide data organization__________________________
br_data_mat=zeros(length(br_cont(:,1)),8,depths);
br_data_mat_reorg=br_data_mat;

count=0;
conc_vms=[2 4 5 7 1 3 6 8];
for vms=1:8
    for depth=1:depths
        count=count+1;
        br_data_mat(:,vms,depth)=br_cont(:,count);
        
    end
end

%adjust to correspond with the order of plots in wc data:
for vms=1:8
    for depth=1:depths
        count=count+1;
        br_data_mat_reorg(:,conc_vms(vms),depth)=br_data_mat(:,vms,depth);
    end
    
end

br_data=br_data_mat_reorg;
save([out_path '\br_data' num2str(depths) '.mat'],'br_data')


