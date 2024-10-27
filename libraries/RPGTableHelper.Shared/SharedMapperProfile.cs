using AutoMapper;
using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.DataLayer
{
    public class SharedMapperProfile : Profile
    {
        public SharedMapperProfile()
        {
            CreateOptionMapForType<bool>();
            CreateOptionMapForType<long>(); // add tests
            CreateOptionMapForType<double>();
            CreateOptionMapForType<float>();
            CreateOptionMapForType<char>(); // add tests
            CreateOptionMapForType<int>(); // add tests
            CreateOptionMapForType<DateOnly>();
            CreateOptionMapForType<TimeOnly>(); // add tests
            CreateOptionMapForType<DateTime>(); // add tests
            CreateOptionMapForType<DateTimeOffset>(); // add tests

            CreateMap<string?, Option<string>>().ConvertUsing((tmid, _) => Option.From(tmid));
            CreateMap<Option<string>, string?>().ConvertUsing((tmid) => (tmid.IsNone ? null : tmid.Get()));

            CreateMap<string, Option<string>>().ConvertUsing((tmid, _) => Option.From(tmid));
            CreateMap<Option<string>, string>().ConvertUsing((tmid) => (tmid.IsNone ? default! : tmid.Get()));
        }

        private void CreateOptionMapForType<T>()
            where T : struct
        {
            CreateMap<T?, Option<T>>().ConvertUsing((tmid, _) => Option.From(tmid));
            CreateMap<Option<T>, T?>().ConvertUsing((tmid) => (T?)(tmid.IsNone ? null : tmid.Get()));
        }
    }
}
