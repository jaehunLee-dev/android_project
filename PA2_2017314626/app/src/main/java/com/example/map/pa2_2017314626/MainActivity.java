package com.example.map.pa2_2017314626;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.AsyncTask;
import android.os.Bundle;
import android.provider.MediaStore;
import android.renderscript.ScriptGroup;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.net.HttpURLConnection;
import java.net.URL;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.HttpUrl;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class MainActivity extends AppCompatActivity {
    Bitmap nono[][] = new Bitmap[20][20];
    Bitmap input_nono[][] = new Bitmap[20][20];
    GridView gridView;
    MyGridAdapter gAdapter;
    int max_1 =0;
    int max_2 =0;
    int num_ver[][] = new int[20][10];
    int num_hor[][] = new int[10][20];
    int answer[][] = new int[20][20];
    int input[][] = new int[20][20];
    int right = 1;
    Bitmap intimg = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        gridView = (GridView) findViewById(R.id.gridView);
        gAdapter = new MyGridAdapter(this);

        Button button1 = (Button)findViewById(R.id.button1);
        Button button2 = (Button) findViewById(R.id.button2);
        EditText editText = (EditText)findViewById(R.id.editText);

        button1.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
            OkHttpClient client =new OkHttpClient();

                HttpUrl.Builder urlBuilder = HttpUrl.parse("https://openapi.naver.com/v1/search/image").newBuilder();
                urlBuilder.addQueryParameter("query",editText.getText().toString());
                String url = urlBuilder.build().toString();

                Request req = new Request.Builder().addHeader("X-Naver-Client-Id","UiMkPxcBy3MeBKguaUZr").
                        addHeader("X-Naver-Client-Secret","5ECwbADXge").url(url).build();

                client.newCall(req).enqueue(new Callback() {
                    @Override
                    public void onFailure(@NotNull Call call, @NotNull IOException e) {
                        e.printStackTrace();
                    }

                    @Override
                    public void onResponse(@NotNull Call call, @NotNull Response response) throws IOException {
                        final String myResponse = response.body().string();
                        Gson gson = new GsonBuilder().create();
                        final DataModel data = gson.fromJson(myResponse,DataModel.class);
                        MainActivity.this.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                try{
                                    BitmapTask bitmapTask = new BitmapTask();
                                    Bitmap _intimg = bitmapTask.execute(data.items[0].getThumbnail()).get();
                                    intimg = Bitmap.createScaledBitmap(_intimg,400,400,true);
                                    makeBitmap(intimg);
                                }
                                catch (Exception e){
                                    Toast.makeText(MainActivity.this, "Error, no result", Toast.LENGTH_SHORT).show();
                                    //finish();}
                                }
                            }
                        });
                    }
                });
            }
        });

        button2.setOnClickListener(new Button.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent();
                intent.setType("image/*");
                intent.setAction(Intent.ACTION_GET_CONTENT);
                startActivityForResult(intent, 1);
            }
        });

        gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    if ((position / (20 + max_1)) >= max_2 && (position % (20 + max_1)) >= max_1&&right!=2) {
                        input[position / (20 + max_1) - max_2][position % (20 + max_1) - max_1] = 1;
                        if (answer[position / (20 + max_1) - max_2][position % (20 + max_1) - max_1] != 1) {
                            Toast.makeText(MainActivity.this, "Wrong", Toast.LENGTH_SHORT).show();
                            input = new int[20][20];
                            for (int i = 0; i < 20; i++) {
                                for (int j = 0; j < 20; j++)
                                    input_nono[i][j].eraseColor(Color.WHITE);
                            }
                        } else {
                            input_nono[position / (20 + max_1) - max_2][position % (20 + max_1) - max_1].eraseColor(Color.BLACK);
                            right = 1;
                            for (int i = 0; i < 20; i++) {
                                for (int j = 0; j < 20; j++) {
                                    if (answer[i][j] != input[i][j])
                                        right = 0;
                                }
                            }
                            if (right == 1){
                                Toast.makeText(MainActivity.this, "Finish!", Toast.LENGTH_LONG).show();
                                right = 2;
                            }
                        }
                    }
                }
        });
    }

    class BitmapTask extends AsyncTask<String, Void, Bitmap>{
            protected Bitmap doInBackground(String... args) {
                Bitmap internet = null;
                try{
                    internet = BitmapFactory.decodeStream((InputStream)new URL(args[0]).getContent());
                }catch (Exception e) {
                    e.printStackTrace();
                }
            return internet;
        }
    }

public class MyGridAdapter extends BaseAdapter{
        Context context;
    public MyGridAdapter(Context c) {
        context = c;
    }


    @Override
    public int getCount() {
        return (20+max_1)*(20+max_2);
    }

    @Override
    public Object getItem(int position) {
        return null;
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ImageView view;
        TextView view2;
        view = new ImageView(context);
        if(max_1>=max_2)
            view.setLayoutParams(new ViewGroup.LayoutParams(50-max_1,50-max_1));
        else
            view.setLayoutParams(new ViewGroup.LayoutParams(50-max_2,50-max_2));
        view.setScaleType(ImageView.ScaleType.FIT_CENTER);
        view.setPadding(5,0,5,0);

        view2 = new TextView(context);
        view2.setPadding(0,0,0,0);
        view2.setSingleLine(true);
        view2.setGravity(Gravity.CENTER_HORIZONTAL|Gravity.CENTER_VERTICAL);
        if ((position%(20+max_1)<max_1)&&(position/(20+max_1)<max_2)){
            view2.setText(" ");
            return view2;
        }
        else if((position%(20+max_1)>=max_1)&&(position/(20+max_1)<max_2)){
            view2.setText(""+num_hor[(position-max_1)/(20+max_1)][(position-max_1)%(20+max_1)]);
            return view2;
        }
        else if ((position%(20+max_1)<max_1)&&(position/(20+max_1)>=max_2)){
            view2.setText(""+num_ver[position/(20+max_1)-max_2][position%(20+max_1)]);
            return view2;
        }
        else{
            view.setImageBitmap(input_nono[position / (20+max_1) - max_2][position % (20+max_1) -max_1]);
            return view;
        }
    }

}


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1) {
            // Make sure the request was successful
            if (resultCode == RESULT_OK) {
                try {
                    // 선택한 이미지에서 비트맵 생성
                    InputStream in = getContentResolver().openInputStream(data.getData());
                    Bitmap _img = BitmapFactory.decodeStream(in);
                    in.close();
                    Bitmap img = Bitmap.createScaledBitmap(_img,400,400,true);
                    makeBitmap(img);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public void makeBitmap(Bitmap img){
        int A=0, R=0, G=0, B=0;
        int pixel=0;
        input = new int[20][20];
        input_nono = new Bitmap[20][20];
        right =1;

        num_ver = new int[20][10];
        num_hor = new int[10][20];
        max_1=1;
        max_2=1;
        answer = new int[20][20];

        for (int x = 0; x < 400; ++x) {
            for (int y = 0; y < 400; ++y) {
                // get pixel color
                pixel = img.getPixel(x, y);
                A = Color.alpha(pixel);
                R = Color.red(pixel);
                G = Color.green(pixel);
                B = Color.blue(pixel);
                int gray = (int) (0.299 * R + 0.587 * G + 0.114 * B);

                // use 128 as threshold, above -> white, below -> black
                if (gray > 128)
                    gray = 255;
                else
                    gray = 0;
                // set new pixel color to output bitmap
                img.setPixel(x, y, Color.argb(A, gray, gray, gray));
            }
        }

        for (int i=0; i<20; i++){
            for(int j=0; j<20; j++){
                nono[i][j] =Bitmap.createBitmap(img,j*(img.getWidth())/20,i*(img.getHeight())/20,
                        img.getWidth()/20, img.getHeight()/20);

                int avg = 0;
                for (int x=0; x<20; ++x){
                    for(int y=0; y<20; ++y) {
                        pixel = nono[i][j].getPixel(x, y);
                        R = Color.red(pixel);
                        if (R == 0)
                            avg++;
                    }
                }
                nono[i][j] = Bitmap.createBitmap(10,10,Bitmap.Config.ARGB_8888);
                input_nono[i][j]= Bitmap.createBitmap(10,10,Bitmap.Config.ARGB_8888);
                input_nono[i][j].eraseColor(Color.WHITE);

                if (avg<200){
                    nono[i][j].eraseColor(Color.WHITE);
                    answer[i][j] = 0;
                }
                else{
                    nono[i][j].eraseColor(Color.BLACK);
                    answer[i][j] = 1;
                }
            }
        }

        for(int i=0; i<20; i++){
            int tmp =0;
            if(Color.red(nono[i][0].getPixel(1,1))==0)
                tmp=1;
            for (int j=0; j<20; j++){
                if (j>0){
                    if (Color.red(nono[i][j].getPixel(1,1)) == 0 &&
                            Color.red(nono[i][j-1].getPixel(1,1))==255)
                        tmp++;
                }
                if(Color.red(nono[i][j].getPixel(1,1))==0)
                    num_ver[i][tmp-1]++;
                if (tmp>max_1)
                    max_1 = tmp;
            }
        }

        for(int i=0; i<20; i++){
            int tmp =0;
            if (Color.red(nono[0][i].getPixel(1,1))==0)
                tmp=1;
            for (int j=0; j<20; j++){
                if (j>0){
                    if (Color.red(nono[j][i].getPixel(1,1))==0&&
                            Color.red(nono[j-1][i].getPixel(1,1))==255)
                        tmp++;
                }
                if(Color.red(nono[j][i].getPixel(1,1))==0)
                    num_hor[tmp-1][i]++;
            }
            if (tmp>max_2)
                max_2 = tmp;
        }
        gridView.setNumColumns(20+max_1);
        gridView.setAdapter(gAdapter);
    }
}