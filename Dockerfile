FROM ubuntu
COPY ./run.sh /
COPY ./test.sh /
RUN chmod +x /test.sh
RUN chmod +x /run.sh
EXPOSE 8080
ENTRYPOINT ["/bin/bash"]  
CMD ["/run.sh"]  
